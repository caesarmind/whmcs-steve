{* Table list - the WHMCS shared include: turns #table<tableName> into a
   DataTable, for code that includes "$template/includes/tablelist.tpl" by
   name (the bundled Project Management addon's client page does). Hadrian's
   own list pages use the unified engine (includes/partials/list-table-assets
   + assets/js/dynamic-tables.js) instead.

   jQuery and DataTables load only when the page has none yet (WHMCS's own
   bundled copies), so a page that already has them keeps its plugins. The
   init matches stock Nexus: same options and parameters - tableName,
   noPagination, noInfo, noSearch, noOrdering, startOrderCol, noSortColumns,
   filterColumn (with the .view-filter-btns links), dontControlActiveClass. *}
<script>
    window.jQuery || document.write('<script src="{$WEB_ROOT}/assets/js/jquery.min.js"><\/script>');
</script>
<script>
    (window.jQuery && jQuery.fn.dataTable) || document.write('<script src="{$WEB_ROOT}/assets/js/jquery.dataTables.min.js"><\/script>');
</script>
<style>{literal}
.listtable{display:flex;flex-direction:column;gap:12px}
.listtable .dataTables_filter input{height:34px;padding:0 12px;border:.5px solid var(--color-border);border-radius:var(--radius-md);background:var(--color-surface);color:var(--color-text-primary);font-family:inherit}
.listtable .dataTables_info{font-size:var(--text-sm);color:var(--color-text-tertiary)}
.dataTables_paginate{display:flex;gap:4px;margin-top:12px;font-size:var(--text-sm)}
.dataTables_paginate .paginate_button{padding:4px 10px;border-radius:var(--radius-sm);cursor:pointer;color:var(--color-text-secondary)}
.dataTables_paginate .paginate_button.current{background:var(--color-accent);color:#fff}
.dataTables_paginate .paginate_button.disabled{opacity:.4;cursor:default}
.dataTables_length{margin-top:8px;font-size:var(--text-sm);color:var(--color-text-tertiary)}
{/literal}</style>

{if isset($filterColumn) && $filterColumn}
<script>
    if (typeof(buildFilterRegex) !== "function") {
        function buildFilterRegex(filterValue) {
            if (filterValue.indexOf('&') === -1) {
                return '[~>]\\s*' + jQuery.fn.dataTable.util.escapeRegex(filterValue) + '\\s*[<~]';
            } else {
                var tempDiv = document.createElement('div');
                tempDiv.innerHTML = filterValue;
                return '\\s*' + jQuery.fn.dataTable.util.escapeRegex(tempDiv.innerText) + '\\s*';
            }
        }
    }

    jQuery(document).ready(function () {
        jQuery(".view-filter-btns a").click(function (e) {
            var filterValue = jQuery(this).find("span").not('.badge').html().trim(),
                dataTable = jQuery('#table{$tableName}').DataTable(),
                filterValueRegex;
            if (jQuery(this).hasClass('active')) {
                {if !isset($dontControlActiveClass) || !$dontControlActiveClass}
                    jQuery(this).removeClass('active');
                {/if}
                dataTable.column({$filterColumn}).search('').draw();
            } else {
                {if !isset($dontControlActiveClass) || !$dontControlActiveClass}
                    jQuery('.view-filter-btns .list-group-item').removeClass('active');
                    jQuery(this).addClass('active');
                {/if}
                filterValueRegex = buildFilterRegex(filterValue);
                dataTable.column({$filterColumn})
                    .search(filterValueRegex, true, false, false)
                    .draw();
            }
            e.preventDefault();
        });
    });
</script>
{/if}

<script>
    var alreadyReady = false;
    jQuery(document).ready( function () {
        var table = jQuery("#table{$tableName}").DataTable({
            "dom": '<"listtable"fit>pl',{if isset($noPagination) && $noPagination}
            "paging": false,{/if}{if isset($noInfo) && $noInfo}
            "info": false,{/if}{if isset($noSearch) && $noSearch}
            "filter": false,{/if}{if isset($noOrdering) && $noOrdering}
            "ordering": false,{/if}
            "oLanguage": {
                "sEmptyTable":     "{lang key='norecordsfound'}",
                "sInfo":           "{lang key='tableshowing'}",
                "sInfoEmpty":      "{lang key='tableempty'}",
                "sInfoFiltered":   "{lang key='tablefiltered'}",
                "sInfoPostFix":    "",
                "sInfoThousands":  ",",
                "sLengthMenu":     "{lang key='tablelength'}",
                "sLoadingRecords": "{lang key='tableloading'}",
                "sProcessing":     "{lang key='tableprocessing'}",
                "sSearch":         "",
                "sZeroRecords":    "{lang key='norecordsfound'}",
                "oPaginate": {
                    "sFirst":    "{lang key='tablepagesfirst'}",
                    "sLast":     "{lang key='tablepageslast'}",
                    "sNext":     "{lang key='tablepagesnext'}",
                    "sPrevious": "{lang key='tablepagesprevious'}"
                }
            },
            "pageLength": 10,
            "order": [
                [
                    {if isset($startOrderCol) && $startOrderCol}{$startOrderCol}{else}0{/if},
                    "asc"
                ]
            ],
            "lengthMenu": [
                [10, 25, 50, -1],
                [10, 25, 50, "{lang key='tableviewall'}"]
            ],
            "aoColumnDefs": [
                {
                    "bSortable": false,
                    "aTargets": [
                        {if isset($noSortColumns) && $noSortColumns !== ''}{$noSortColumns}{/if}
                    ]
                },
                {
                    "sType": "string",
                    "aTargets": [
                        {if isset($filterColumn) && $filterColumn}{$filterColumn}{/if}
                    ]
                }
            ],
            "stateSave": true
        });

        {if isset($filterColumn) && $filterColumn}
        var rememberedFilterTerm = table.state().columns[{$filterColumn}].search.search;
        if (rememberedFilterTerm && !alreadyReady) {
            jQuery(".view-filter-btns a span").each(function (index) {
                if (buildFilterRegex(jQuery(this).text().trim()) == rememberedFilterTerm) {
                    jQuery(this).closest('a').addClass('active');
                }
            });
        }
        {/if}
        alreadyReady = true;
    });
</script>
