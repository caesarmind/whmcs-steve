{*
 * Remove-item confirm modal.
 *
 * Trigger: every .ct-product-remove button calls removeItem(type, ref[, rType])
 *          (inline scripts.min.js helper). That populates the three hidden
 *          inputs below and opens the modal.
 * Submit:  POST to /cart.php with a=remove + r=type + i=ref + rt=renewalType.
 *}
<form method="post" action="{$WEB_ROOT}/cart.php">
    <input type="hidden" name="a" value="remove">
    <input type="hidden" name="r" value="" id="inputRemoveItemType">
    <input type="hidden" name="i" value="" id="inputRemoveItemRef">
    <input type="hidden" name="rt" value="" id="inputRemoveItemRenewalType">
    <div class="modal fade modal-remove-item" id="modalRemoveItem" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <div class="float-right">
                        <button type="button" class="close" data-dismiss="modal" aria-label="{lang key='orderForm.close'}"><span aria-hidden="true">&times;</span></button>
                    </div>
                    <h4 class="modal-title margin-bottom mb-3">
                        <i class="fas fa-times fa-3x"></i>
                        <span>{lang key='orderForm.removeItem'}</span>
                    </h4>
                    {lang key='cartremoveitemconfirm'}
                </div>
                <div class="modal-footer justify-content-center">
                    <button type="button" class="btn btn-default" data-dismiss="modal">{lang key='no'}</button>
                    <button type="submit" class="btn btn-primary">{lang key='yes'}</button>
                </div>
            </div>
        </div>
    </div>
</form>
