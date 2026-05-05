{* =========================================================================
   payment/card/validate.tpl — client-side validation rules for card fields.
   ========================================================================= *}
<script>
    jQuery(document).ready(function() {
        jQuery('#frmPayment, form.using-payment-inputs').submit(function(e) {
            var form = jQuery(this);
            var ccnumber = form.find('#ccnumber').val();
            var ccexpires = form.find('#ccexpires').val();
            var cccvv = form.find('#cccvv').val();
            var errors = [];

            if (!ccnumber || ccnumber.replace(/\s/g, '').length < 13) {
                errors.push("{lang|addslashes key='creditcardmustenterccnumber'}");
            }
            if (!ccexpires || !/^\d{2}\/\d{2}$/.test(ccexpires)) {
                errors.push("{lang|addslashes key='creditcardmustenterccexpires'}");
            }
            if (!cccvv || cccvv.length < 3) {
                errors.push("{lang|addslashes key='creditcardmustentercccvv'}");
            }

            if (errors.length > 0) {
                e.preventDefault();
                alert(errors.join("\n"));
            }
        });
    });
</script>
