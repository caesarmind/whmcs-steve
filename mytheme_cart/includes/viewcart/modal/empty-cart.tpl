{*
 * Empty-cart confirm modal.
 *
 * Trigger: #btnEmptyCart click opens this modal (wired inline in viewcart.tpl).
 * Submit:  POST to /cart.php with a=empty, clears the cart server-side.
 *}
<form method="post" action="{$WEB_ROOT}/cart.php">
    <input type="hidden" name="a" value="empty">
    <div class="modal fade modal-remove-item" id="modalEmptyCart" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <div class="float-right">
                        <button type="button" class="close" data-dismiss="modal" aria-label="{$LANG.orderForm.close}"><span aria-hidden="true">&times;</span></button>
                    </div>
                    <h4 class="modal-title margin-bottom mb-3">
                        <i class="fas fa-trash-alt fa-3x"></i>
                        <span>{$LANG.emptycart}</span>
                    </h4>
                    {$LANG.cartemptyconfirm}
                </div>
                <div class="modal-footer justify-content-center">
                    <button type="button" class="btn btn-default" data-dismiss="modal">{$LANG.no}</button>
                    <button type="submit" class="btn btn-primary">{$LANG.yes}</button>
                </div>
            </div>
        </div>
    </div>
</form>
