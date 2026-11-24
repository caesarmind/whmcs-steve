{* Page header - the WHMCS (Six-era) shared include, for module templates
   that include "$template/includes/pageheader.tpl" by name (the bundled
   ResellerClub registrar does). Parameters: title, desc. *}
<header class="page-header">
    <h1>{$title}</h1>
    {if isset($desc) && $desc}<p class="page-subtitle">{$desc}</p>{/if}
</header>
