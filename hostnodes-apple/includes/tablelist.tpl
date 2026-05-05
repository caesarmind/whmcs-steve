{* =========================================================================
   DataTables initialisation for apple-styled tables. WHMCS emits a table with
   id="table{$tableName}" and this include attaches the DataTable behavior.
   Apple CSS styles .dataTables_paginate / .dataTables_length / .dataTables_info
   to match the theme (see _pagination in theme.scss).
   ========================================================================= *}
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
                    jQuery('.view-filter-btns .filter-tab').removeClass('active');
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
            "responsive": true,
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
            "order": [[{if isset($startOrderCol) && $startOrderCol}{$startOrderCol}{else}0{/if}, "asc"]],
            "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "{lang key='tableviewall'}"]],
            "aoColumnDefs": [
                {
                    "bSortable": false,
                    "aTargets": [{if isset($noSortColumns) && $noSortColumns !== ''}{$noSortColumns}{/if}]
                },
                {
                    "sType": "string",
                    "aTargets": [{if isset($filterColumn) && $filterColumn}{$filterColumn}{/if}]
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
