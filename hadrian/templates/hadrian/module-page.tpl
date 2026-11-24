{* A page whose body an extension module built.

   A separate addon (Hadrian Page Builder is the first) renders its page to a
   string and asks WHMCS for this template, so the page gets the theme's
   header, navigation and footer like every other one. The theme knows
   nothing about what is in the string.

     $modulePageHtml  the page body, already escaped by the module that made it
     $modulePage      module, id, slug, title, description, preview

   header.tpl gives this template the same full-width content area as the
   store landing pages. *}
{$modulePageHtml nofilter}
