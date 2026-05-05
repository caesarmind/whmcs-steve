{* =========================================================================
   payment/bank/validate.tpl — client-side validation for bank fields.
   ========================================================================= *}
<script>
    jQuery(document).ready(function() {
        jQuery('#frmPayment, form.using-payment-inputs').submit(function(e) {
            var form = jQuery(this);
            var routing = form.find('#bankroutingno').val();
            var account = form.find('#bankacctno').val();
            var errors = [];

            if (!routing || routing.length < 9) {
                errors.push("{lang|addslashes key='bankRoutingNumberRequired'}");
            }
            if (!account || account.length < 4) {
                errors.push("{lang|addslashes key='bankAccountNumberRequired'}");
            }

            if (errors.length > 0) {
                e.preventDefault();
                alert(errors.join("\n"));
            }
        });
    });
</script>
