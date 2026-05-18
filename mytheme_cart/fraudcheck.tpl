{*
 * mytheme_cart/fraudcheck.tpl
 *
 * Order is placed, but WHMCS' fraud module has flagged it for manual
 * review. Two paths:
 *
 *   1. User-validation path ($userValidation && $userValidation.token):
 *      open a modal iframe pointing at $userValidationUrl so the
 *      visitor can complete an ID-document upload flow served by the
 *      external validation host. The "camera" allow attribute on the
 *      iframe is critical (mobile selfie capture).
 *
 *   2. Fallback: show the $error string + a "Submit Ticket" CTA.
 *
 * Contract preserved verbatim:
 *   - openValidationSubmitModal() global handler from scripts.min.js.
 *   - #validationSubmitModal Bootstrap-modal node + #validationContent
 *     iframe id (scripts.min.js sets its src on open).
 *   - data-dismiss="modal" on the close button.
 *   - allow="camera {$userValidationHost}" attribute string format.
 *}

{include file="orderforms/$carttpl/common.tpl"}

<div id="order-standard_cart">

    <div class="row">
        <div class="cart-sidebar">
            {include file="orderforms/$carttpl/sidebar-categories.tpl"}
        </div>

        <div class="cart-body">

            {include file="orderforms/$carttpl/sidebar-categories-collapsed.tpl"}

            {* ─── Apple fraud-hold hero ─── *}
            <div class="order-fraud-hero">
                <div class="order-fraud-ico">
                    <i class="fas fa-shield-alt"></i>
                </div>
                <h1 class="font-size-36">{$LANG.cartfraudcheck}</h1>
                {if $errortitle}
                    <p class="order-fraud-title">{$errortitle}</p>
                {/if}
            </div>

            <div class="row">
                <div class="col-sm-8 col-sm-offset-2 offset-sm-2 text-center">

                    {if $userValidation && !$userValidation.submittedAt && $userValidation.token eq true}

                        <div class="alert alert-warning order-fraud-body">
                            <i class="fas fa-id-card"></i>
                            <span>{lang key='fraud.furtherVal'}</span>
                        </div>

                        <div class="order-fraud-actions">
                            <a href="#"
                               class="btn btn-primary btn-lg"
                               data-url="{$userValidationUrl}"
                               onclick="openValidationSubmitModal(this);return false;">
                                {lang key='fraud.submitDocs'}
                                &nbsp;<i class="fas fa-arrow-right"></i>
                            </a>
                        </div>

                        <div id="validationSubmitModal" class="modal fade" role="dialog">
                            <div class="modal-dialog modal-lg">
                                <div class="modal-content">
                                    <div class="modal-body top-margin-10">
                                        <iframe id="validationContent"
                                                allow="camera {$userValidationHost}"
                                                width="100%"
                                                height="700"
                                                frameborder="0"
                                                src=""></iframe>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-default" data-dismiss="modal">
                                            {lang key='close'}
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>

                    {else}

                        {if $error}
                            <div class="alert alert-danger order-fraud-body">
                                <i class="fas fa-info-circle"></i>
                                <span>{$error}</span>
                            </div>
                        {/if}

                        <div class="order-fraud-actions">
                            <a href="{$WEB_ROOT}/submitticket.php" class="btn btn-primary btn-lg">
                                {$LANG.orderForm.submitTicket}
                                &nbsp;<i class="fas fa-arrow-right"></i>
                            </a>
                            <br><br>
                            <a href="{$WEB_ROOT}/clientarea.php" class="btn-link order-fraud-back">
                                <i class="fas fa-arrow-circle-left"></i>
                                {$LANG.orderForm.returnToClientArea}
                            </a>
                        </div>

                    {/if}

                </div>
            </div>

        </div>
    </div>
</div>
