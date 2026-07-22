{*
    One not-yet-wired Layouts control.

    Deliberately rendered OUTSIDE any <form> and with the input disabled, so it
    cannot be submitted even by a crafted request — a placeholder must not be
    able to write a setting that nothing reads.

    $row is a PLANNED_CONTROLS tuple: [label, help, type, choices]
*}
<div class="mt-row mt-row-planned">
    <div>
        <div class="mt-row-label">
            {$row[0]|escape}
            <span class="mt-badge mt-badge-neutral mt-planned-tag">Not wired</span>
        </div>
        <div class="mt-row-help">{$row[1]|escape}</div>
    </div>

    {if $row[2] == 'select'}
        {* data-mt-native: opt out of the styled listbox. `disabled` already
           excludes it, but this makes the intent explicit for a placeholder. *}
        <select class="mt-select mt-planned-select" disabled data-mt-native aria-label="{$row[0]|escape} (not wired yet)">
            {foreach $row[3] as $choice}
                <option>{$choice|escape}</option>
            {/foreach}
        </select>
    {else}
        <label class="mt-toggle mt-planned-toggle">
            <input type="checkbox" disabled aria-label="{$row[0]|escape} (not wired yet)">
            <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
        </label>
    {/if}
</div>
