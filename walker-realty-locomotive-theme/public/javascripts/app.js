// Foundation JavaScript
// Documentation can be found at: http://foundation.zurb.com/docs
$(document).foundation();

function isEmail(email) {
  var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
  return regex.test(email);
}

function isPhone(phone) {
    var number = phone.replace(/\D/g, '');
    var regex = /(\d{11})|(\d{10})|(\d{7})/;
    return regex.test(number);
}

$.fn.serializeObject = function()
{
    var o = {};
    var a = this.serializeArray();
    $.each(a, function() {
        if (o[this.name] !== undefined) {
            if (!o[this.name].push) {
                o[this.name] = [o[this.name]];
            }
            o[this.name].push(this.value || '');
        } else {
            o[this.name] = this.value || '';
        }
    });
    return o;
};

$(function() {
    function resetNewsletterForm() {
        $("#newletter-error").addClass("hide");
        $("#newsletter-button").removeClass("hide");
        $("#newsletter-spin").addClass("hide");
    }

    function invalidEmail() {
        $("#newsletter-spin").addClass("hide");
        $("#newsletter-error").removeClass("hide");
        $("#newsletter-button").removeClass("hide");
    }

    function validEmail() {
        $("#newsletter-spin").addClass("hide");
        $("#newsletter-form").addClass("hide");
        $("#newsletter-button").addClass("hide");
        $("#newsletter-success").removeClass("hide");
    }


    $(document).on('submit', 'form#newsletter', function() {
        resetNewsletterForm();
        
        if (!isEmail($("#newsletter-email").val())) {
            invalidEmail();
            return false;
        }
        
        var spinner = new Spinner().spin(document.getElementById('newsletter-spin'));

        $.ajax({
            url     : $(this).attr('action') + ".json",
            type    : $(this).attr('method'),
            data    : $(this).serialize(),
            dataType: 'json',
            success : function( data ) {
                spinner.stop();
                validEmail();
                
            },
            error   : function( xhr, err, strError ) {
                spinner.stop();
                invalidEmail();
            }
        }); 
        return false;
    });
});
