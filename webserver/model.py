from sqlalchemy import Column, PickleType, Boolean, Text, DateTime
from sqlalchemy import ForeignKey
from sqlalchemy import Integer
from sqlalchemy import MetaData
from sqlalchemy import String
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import datetime

DEFAULT_DATABASE = 'lsb_check.db'

engine = create_engine('sqlite:///%s' % DEFAULT_DATABASE, echo=False)
metaData = MetaData()
metaData.bind = engine

Session = sessionmaker(bind=engine)
Base = declarative_base(metadata=metaData)


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    name = Column(String, default="")
    group = Column(Integer, default=1)


class Answer(Base):
    __tablename__ = "answers"

    id = Column(Integer, primary_key=True)
    stamp_id = Column(Integer, ForeignKey("stamps.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    artifact = Column(Boolean)
    border = Column(Boolean)
    detection = Column(Boolean)
    flag = Column(Boolean)
    coordinates = Column(Text, default="")
    notes = Column(Text, default="")
    datetime = Column(DateTime, default=datetime.datetime.utcnow)

class Stamp(Base):
    __tablename__ = "stamps"

    id = Column(Integer, primary_key=True, autoincrement=True)
    number = Column(Integer, unique=True)
    xypos = Column(String, default="")
    wcs = Column(PickleType, default=None)
    file_prefix = Column(String, default="")  # i.e.: /Users/william/data/ngc3115/work/stamps_test/0085/stamp_0085
    group = Column(Integer, default=0)  # Group to be assigned the stamp. 0 = all users will receive this stamp
    # user_id = Column(Integer, ForeignKey("users.id"))
    # answer = Column(String, default="")



metaData.create_all(engine)
