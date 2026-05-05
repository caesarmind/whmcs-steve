{* =========================================================================
   announcements.tpl — list of site announcements.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='announcementstitle'}</h1></div>

{foreach $announcements as $announcement}
    <a href="{routePath('announcement-view', $announcement.id, $announcement.urlfriendlyname)}" class="card announcement-link">
        <div class="card-body">
            <div class="announcement-date">{$announcement.date}</div>
            <h3 class="announcement-title">{$announcement.title}</h3>
            <p class="announcement-excerpt">{$announcement.announcement|strip_tags|truncate:200:"..."}</p>
        </div>
    </a>
{foreachelse}
    {include file="$template/includes/alert.tpl" type="info" msg="{lang key='noannouncements'}" textcenter=true}
{/foreach}
