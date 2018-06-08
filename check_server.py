import operator
import os
from copy import copy, deepcopy

from bottle import route, run, response, request, post, template, static_file, get
from sqlalchemy import or_
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.sql.functions import count, func

from webserver.model import Session, User, Answer, Stamp

session = Session()


@route('/')
def main(user=None):
    user = user if user is not None else request.get_cookie("user")
    if user is None:
        return update_form()
    else:
        user = session.query(User).filter(User.name == user).first()
        if user is not None:
            user_id = user.id
            user_group = user.group
        else:
            return update_form()
        answers = session.query(Answer.stamp_id).filter(Answer.user_id == user_id)
        stamp = session.query(Stamp).filter(Stamp.id.notin_(answers),
                                            or_(Stamp.group == user_group, Stamp.group == 0)).first()
        if stamp is not None:
            info = {"name": user.name,
                    "stamp_id": stamp.id,
                    "stamp_number": stamp.number}
            return template("templates/webpage.tpl", info)
        else:
            return template("User: {{name}} <a href=\"/update_name\">(change)</a><br><br>All stamps checked! :-)<br>",
                            {"name": user.name})


@post('/goto')
def goto_stamp(user=None, goto_stamp_id=None):
    user = user if user is not None else request.get_cookie("user")
    goto_stamp_id = goto_stamp_id if goto_stamp_id is not None else request.forms.get("goto_stamp_id")

    user_id = session.query(User).filter(User.name == user).first()
    if user_id is not None:
        user_id = user_id.id
    else:
        return update_form()
    answer = session.query(Answer).filter(Answer.user_id == user_id).filter(Answer.stamp_id == goto_stamp_id).first()
    if answer is not None:
        stamp = session.query(Stamp).filter(Stamp.id == answer.stamp_id).first()
        info = stamp.__dict__
        data = answer.__dict__
        info.update(data)
        info.update({"name": user, "stamp_number": info['number']})
        for var in ('artifact', 'border', 'detection', 'flag'):
            info.update({var: 'checked' if info[var] else ''})
        return template("templates/webpage.tpl", info)
    else:
        return "<b>Stamp not processed yet!</b><br>" + main(user=user)


@get('/answer_list')
def answer_list(user=None):
    user = user if user is not None else request.get_cookie("user")
    if user is None:
        return update_form()
    else:
        user_id = session.query(User).filter(User.name == user).first()
        if user_id is not None:
            user_id = user_id.id
        else:
            return update_form()

    data = {"name": user}
    answers = session.query(Answer).filter(Answer.user_id == user_id).all()
    tbdata = ""
    for a in answers:
        d = deepcopy(a.__dict__)
        for p in ('artifact', 'border', 'flag', 'detection'):
            d[p] = "X" if d[p] else ""
        for p in ("notes", "coordinates"):
            d[p] = d[p].replace("\n", "<br>")  # .replace("\r", "<br>")
        tbdata += "<tr><td align=\"center\">{stamp_id}</td><td align=\"center\">{artifact}</td><td align=\"center\">{border}</td><td align=\"center\">{flag}</td><td>{coordinates}</td><td>{notes}</td></tr>".format(
            **d)

    data["tbdata"] = tbdata
    return template("templates/answer_list.tpl", data)


@post('/answer')
def answer():
    try:
        user = session.query(User).filter(User.name == request.get_cookie("user")).one()
    except NoResultFound:
        session.add(User(name=request.get_cookie("user")))
        session.commit()
        user = session.query(User).filter(User.name == request.get_cookie("user")).one()

    # Check if is an update..
    answer = session.query(Answer).filter(Answer.user_id == user.id,
                                          Answer.stamp_id == request.forms.get('stamp_id')).first()
    if answer is not None:
        answer = session.query(Answer).filter(Answer.user_id == user.id,
                                              Answer.stamp_id == request.forms.get('stamp_id'))
        answer.update(dict(artifact=bool(request.forms.get('artifact')),
                           border=bool(request.forms.get('border')),
                           detection=bool(request.forms.get('detection')),
                           flag=bool(request.forms.get('flag')),
                           coordinates=request.forms.get('coordinates'),
                           notes=request.forms.get('notes')))
        return "<b>Stamp Updated!</b><br>" + goto_stamp(goto_stamp_id=request.forms.get('stamp_id'))
    else:
        session.add(Answer(user_id=user.id,
                           stamp_id=request.forms.get('stamp_id'),
                           artifact=bool(request.forms.get('artifact')),
                           border=bool(request.forms.get('border')),
                           detection=bool(request.forms.get('detection')),
                           flag=bool(request.forms.get('flag')),
                           coordinates=request.forms.get('coordinates'),
                           notes=request.forms.get('notes')
                           ))
    session.commit()

    return main()


@route('/update_name')
def update_form():
    ret = '''
    <form method="post" action="/update_name">
    <input name="user" type="text" value="%s">
    <input name="submit" value="update" type="submit">
    </form>
    ''' % request.get_cookie("user", "guest")

    return ret


@post('/update_name')
def update_name():
    try:
        user = session.query(User).filter(User.name == request.forms.get('user')).one()
    except NoResultFound:
        groups = {g.group: g.count for g in
                  session.query(func.count(User.group).label("count"), User.group).group_by(User.group).all()}
        print(groups)
        avail_groups = [1, 2]  # FIXME: this must not be hardcoded!
        if None in groups.keys():
            group = avail_groups[0]
        elif len(groups.keys()) < len(avail_groups):
            group = set(avail_groups).difference(set(groups)).pop()
        else:
            group = min(groups.items(), key=operator.itemgetter(1))[0]
        session.add(User(name=request.forms.get("user"), group=group))
        session.commit()

    response.set_cookie("user", request.forms.get('user'))
    return "Updated username: %s\n%s" % (request.forms.get('user'), main(user=request.forms.get('user')))


@route('/img/stamp_<stamp_id:int>_<imgtyp><ext:re:\.(png|fits\.fz)>')
# @route('/img/stamp_<stamp_id:int><ext:re:\.(png|fits\.fz)>')
def get_image(stamp_id, ext, imgtyp=None):
    img_prefix = session.query(Stamp).filter(Stamp.id == stamp_id).one().file_prefix
    if imgtyp is not None:
        filename = "%s_%s%s" % (img_prefix, imgtyp, ext)
    else:
        filename = "%s%s" % (img_prefix, ext)
    print(filename)
    return static_file(os.path.basename(filename), root=os.path.dirname(filename), mimetype='image/%s' % ext)


if __name__ == '__main__':
    # Remove reloader for production
    # run(host='localhost', port=8080, reloader=True)
    run(host='0.0.0.0', port=8080, reloader=True)
