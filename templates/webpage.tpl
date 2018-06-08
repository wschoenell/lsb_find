<!DOCTYPE html>
<html lang="en">
<head>
    <style>

        * {
            box-sizing: border-box;
        }

        .img-zoom-container {
            position: relative;
        }

        .img-zoom-lens {
            position: absolute;
            border: 1px solid #d4d4d4;
            /*set the size of the lens:*/
            width: 40px;
            height: 40px;
        }

        .img-zoom-result {
            border: 1px solid #d4d4d4;
            /*set the size of the result div:*/
            width: 300px;
            height: 300px;
        }

        #imgZoom {
            /*float: right;*/
            position: absolute;
            width: 300px;
            height: 300px;
        }

        #blinkImg {
            /*float: right;*/
            position: absolute;
            width: 880px; /* Set your image width */
            height: 880px; /* Set your image height */
        }

        #blinkImg img {
            display: none;
            position: absolute;
            top: 0;
            left: 0;
        }

        #blinkImg img.active {
            display: block;
        }
    </style>
    <meta charset="UTF-8">
    <title>LSB object finder</title>
</head>
<body style="height: 2000px">
<script type="text/javascript">

    (function () {

        var answer1 = "a";
        var answer2 = "b";
        var answer3 = "d";
        var answer4 = "f";
        var submit = "s";
        var blink = "n";
        var add_coordinate = ".";

        document.onkeypress = function (oPEvt) {
            var oEvent = oPEvt || window.event, nChr = oEvent.charCode,
                sNodeType = oEvent.target.nodeName.toUpperCase();
            if (nChr === 0 || oEvent.target.contentEditable.toUpperCase() === "TRUE" || sNodeType === "TEXTAREA" || sNodeType === "INPUT" && oEvent.target.type.toUpperCase() === "TEXT") {
                return true;
            }
            if (nChr === answer1.charCodeAt(0)) {
                // if (confirm("Confirm answer ?")) {
                //     post("/answer", {"answer": "a", "user": "guest"}, "post")
                // }
                if ($("#artifact").prop("checked") === true) {
                    $("#artifact").prop("checked", false)
                } else {
                    $("#artifact").prop("checked", true)
                }
            }
            else if (nChr === answer2.charCodeAt(0)) {
                if ($("#border").prop("checked") === true) {
                    $("#border").prop("checked", false)
                } else {
                    $("#border").prop("checked", true)
                }
            }
            else if (nChr === answer3.charCodeAt(0)) {
                if ($("#detection").prop("checked") === true) {
                    $("#detection").prop("checked", false)
                } else {
                    $("#detection").prop("checked", true)
                }
            }
            else if (nChr === answer4.charCodeAt(0)) {
                if ($("#flag").prop("checked") === true) {
                    $("#flag").prop("checked", false)
                } else {
                    $("#flag").prop("checked", true)
                }
            }
            else if (nChr === submit.charCodeAt(0)) {
                if (confirm("Submit form?")) {
                    $("#form").submit();
                }

            }
            else if (nChr === blink.charCodeAt(0)) {
                $("#blink").click();

            }
            else if (nChr === add_coordinate.charCodeAt(0)) {
                $("#add_coordinate").click();

            }
            return true;
        };
    })();

    // function post(path, params, method) {
    //     method = method || "post"; // Set method to post by default if not specified.
    //
    //     // The rest of this code assumes you are not using a library.
    //     // It can be made less wordy if you use one.
    //     var form = document.createElement("form");
    //     form.setAttribute("method", method);
    //     form.setAttribute("action", path);
    //
    //     for (var key in params) {
    //         if (params.hasOwnProperty(key)) {
    //             var hiddenField = document.createElement("input");
    //             hiddenField.setAttribute("type", "hidden");
    //             hiddenField.setAttribute("name", key);
    //             hiddenField.setAttribute("value", params[key]);
    //
    //             form.appendChild(hiddenField);
    //         }
    //     }
    //
    //     document.body.appendChild(form);
    //     form.submit();
    // }

</script>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>

<script type="text/javascript">
    function swapImages() {
        var $active = $('#blinkImg img.active');
        var $next = ($('#blinkImg img.active').nextAll("img").length > 0) ? $('#blinkImg img.active').nextAll("img") : $('#blinkImg img:first');
        $next.splice(1);
        console.log("active: " + $active[0].id);
        console.log("next: " + $next[0].id);
        imageZoom($next[0].id, "imgZoom");
        $active.fadeOut(1, function () {
                $active.removeClass('active');
                $next.fadeIn(1).addClass('active');
            }
        );
    }

    function findPos(obj) {
        var posX = obj.offsetLeft;
        var posY = obj.offsetTop;
        while (obj.offsetParent) {
            if (obj == document.getElementsByTagName('body')[0]) {
                break
            }
            else {
                posX = posX + obj.offsetParent.offsetLeft;
                posY = posY + obj.offsetParent.offsetTop;
                obj = obj.offsetParent;
            }
        }
        var posArray = [posX, posY];
        return posArray;
    }


    function imageZoom(imgID, resultID) {
        var img, lens, result, cx, cy;
        img = document.getElementById(imgID);
        result = document.getElementById(resultID);
        /*create lens:*/
        if (document.contains(document.getElementById("img-zoom-lens"))) {
            document.getElementById("img-zoom-lens").remove();
            // } else {
            //     lastDiv.appendChild(submitButton);
        }

        lens = document.createElement("DIV");
        lens.setAttribute("class", "img-zoom-lens");
        /*insert lens:*/
        img.parentElement.insertBefore(lens, img);
        /*calculate the ratio between result DIV and lens:*/
        cx = result.offsetWidth / lens.offsetWidth;
        cy = result.offsetHeight / lens.offsetHeight;
        /*set background properties for the result DIV*/
        result.style.backgroundImage = "url('" + img.src + "')";
        result.style.backgroundSize = (img.width * cx) + "px " + (img.height * cy) + "px";
        /*execute a function when someone moves the cursor over the image, or the lens:*/
        lens.addEventListener("mousemove", moveLens);
        img.addEventListener("mousemove", moveLens);
        /*and also for touch screens:*/
        lens.addEventListener("touchmove", moveLens);
        img.addEventListener("touchmove", moveLens);

        function moveLens(e) {
            var pos, x, y;
            /*prevent any other actions that may occur when moving over the image*/
            e.preventDefault();
            /*get the cursor's x and y positions:*/
            pos = getCursorPos(e);
            /*calculate the position of the lens:*/
            x = pos.x - (lens.offsetWidth / 2);
            y = pos.y - (lens.offsetHeight / 2);
            /*prevent the lens from being positioned outside the image:*/
            if (x > img.width - lens.offsetWidth) {
                x = img.width - lens.offsetWidth;
            }
            if (x < 0) {
                x = 0;
            }
            if (y > img.height - lens.offsetHeight) {
                y = img.height - lens.offsetHeight;
            }
            if (y < 0) {
                y = 0;
            }
            /*set the position of the lens:*/
            lens.style.left = x + "px";
            lens.style.top = y + "px";
            /*display what the lens "sees":*/
            result.style.backgroundPosition = "-" + (x * cx) + "px -" + (y * cy) + "px";
        }

        function getCursorPos(e) {
            var a, x = 0, y = 0;
            e = e || window.event;
            /*get the x and y positions of the image:*/
            a = img.getBoundingClientRect();
            /*calculate the cursor's x and y coordinates, relative to the image:*/
            x = e.pageX - a.left;
            y = e.pageY - a.top;
            /*consider any page scrolling:*/
            x = x - window.pageXOffset;
            y = y - window.pageYOffset;
            return {x: x, y: y};
        }
    }

    $(document).ready(function () {

        $("#img4").on("click", function (event) {
            var pos = findPos(this);
            var x = event.pageX - pos[0];
            var y = document.getElementById('img4').clientHeight - event.pageY + pos[1];
            $('#coordinate').text(x + ", " + y)
        });
        $("#img5").on("click", function (event) {
            var pos = findPos(this);
            var x = event.pageX - pos[0];
            var y = document.getElementById('img5').clientHeight - event.pageY + pos[1];
            $('#coordinate').text(x + ", " + y)
        });
        $("#img6").on("click", function (event) {
            var pos = findPos(this);
            var x = event.pageX - pos[0];
            var y = document.getElementById('img6').clientHeight - event.pageY + pos[1];
            $('#coordinate').text(x + ", " + y)
        });
        $("#img7").on("click", function (event) {
            var pos = findPos(this);
            var x = event.pageX - pos[0];
            var y = document.getElementById('img7').clientHeight - event.pageY + pos[1];
            $('#coordinate').text(x + ", " + y)
        });

        var interval = null;

        $('#blink').on("click", function (event) {
            swapImages();
            clearInterval(interval);
            // interval = setInterval('swapImages()', 5000);
        });

        $("#add_coordinate").on("click", function (event) {
            var txt = $.trim($("#coordinate").text());
            // alert(txt);
            $("#coordinates").val($("#coordinates").val() + txt + "\n");
        })
        imageZoom("img4", "imgZoom");
    });
</script>


<form id="form_goto" method="post" action="/goto">
User: {{name}} <a href="/update_name">(change)</a> <a href="/answer_list">(my answers)</a> <br>
Stamp: <input type="text" name="goto_stamp_id" value="{{stamp_id}}" size="3"> <input type="submit" name="submit_goto"
                                                                                     value="GO">
({{stamp_number}})<br>
</form>
<form id="form" method="post" action="/answer">
    <input type="hidden" name="stamp_id" value="{{stamp_id}}">
    <input type="checkbox" id="artifact" name="artifact" value=1 {{get('artifact', '')}}><label for="artifact">Artifact</label><br>
    <input type="checkbox" id="border" name="border" value=1 {{get('border', '')}}><label for="border">Border</label><br>
    <!--<input type="checkbox" id="detection" name="detection" value=1 {{get('detection', '')}}><label for="detection">Detection</label><br>-->
    <input type="checkbox" id="flag" name="flag" value=1  {{get('flag', '')}}><label for="flag">Flag This!</label><br>
    Coordinates list:<br>
    <textarea id="coordinates" name="coordinates">{{get('coordinates', '')}}</textarea><br>
    (x,y) coordinate:<br><input id="add_coordinate" type="button" value="ADD">
    <label id="coordinate"></label><br>
    Notes:<br>
    <textarea name="notes">{{get('notes', '')}}</textarea><br>
    <input name="submit_form" id="submit_form" value="submit" type="submit">
</form>

<br>
<input id="blink" type="button" value="BLINK">
GET FITS: <a href="img/stamp_{{stamp_id}}_img.fits.fz">COMBINED</a> <a href="img/stamp_{{stamp_id}}_r_img.fits.fz">R</a>
<a href="img/stamp_{{stamp_id}}_g_img.fits.fz">G</a>
<br>

<table>
    <tr>
        <td width="300px" height="300px" valign="top">
            <div id="imgZoom" class="img-zoom-result" style="display:inline;"></div>
        </td>
        <!--</tr>-->
        <!--<tr>-->
        <td width="880px" height="880px" valign="top">
            <div id="blinkImg" style="display:inline;">
                <img id="img4" src="img/stamp_{{stamp_id}}_1.png" class="active" ismap>
                <img id="img5" src="img/stamp_{{stamp_id}}_2.png" ismap>
                <img id="img6" src="img/stamp_{{stamp_id}}_3.png" ismap>
                <img id="img7" src="img/stamp_{{stamp_id}}_5.png" ismap>
            </div>
        </td>
    </tr>
</table>

<!--<br>-->
<!--<b>G IMAGE</b><br>-->
<!--<img src="img/stamp_{{stamp_id}}_2_g.png">-->

<!--<b>R IMAGE</b><br>-->
<!--<img src="img/stamp_{{stamp_id}}_2_r.png">-->


<!--<div id="blinkImg" style="display:inline;">-->
<!--<img id="img4" src="../tests/img/stamp_0001_1.png" class="active" ismap>-->
<!--<img id="img5" src="../tests/img/stamp_0001_2.png" ismap>-->
<!--<img id="img6" src="../tests/img/stamp_0001_3.png" ismap>-->
<!--</div>-->

<!--<div style="display:inline;">-->
<!--<img id="img1" src="img/stamp_{{stamp_id}}_1.png" ismap>-->
<!--<label id="coordinate1"></label>-->
<!--</div>-->

<!--<div style="display:inline;">-->
<!--<img id="img2" src="img/stamp_{{stamp_id}}_2.png" ismap>-->
<!--</div>-->

<!--<div style="display:inline;">-->
<!--<img id="img3" src="img/stamp_{{stamp_id}}_3.png" ismap>-->
<!--</div>-->


</body>
</html>