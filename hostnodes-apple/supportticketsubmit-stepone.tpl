{* =========================================================================
   supportticketsubmit-stepone.tpl — choose department to open a ticket in.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='createNewSupportRequest'}</h1>
    <p class="page-subtitle">{lang key='supportticketsheader'}</p>
</div>

<div class="card">
    <div class="card-body">
        {foreach $departments as $department}
            <a href="{$smarty.server.PHP_SELF}?step=2&amp;deptid={$department.id}" class="service-item">
                <div class="service-icon"><i class="fas fa-envelope"></i></div>
                <div class="service-info">
                    <div class="service-name">{$department.name}</div>
                    {if $department.description}<div class="service-domain">{$department.description}</div>{/if}
                </div>
                <span class="service-chevron"><i class="fas fa-chevron-right"></i></span>
            </a>
        {foreachelse}
            {include file="$template/includes/alert.tpl" type="info" msg="{lang key='nosupportdepartments'}" textcenter=true}
        {/foreach}
    </div>
</div>
