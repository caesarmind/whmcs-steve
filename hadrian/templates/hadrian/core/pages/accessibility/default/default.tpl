{* Accessibility statement (European Accessibility Act, Annex V).
   Wording: $hadrianLang.a11yStatement. Site-owner answers: this page's
   options ($hadrian.pages.accessibility.options), all optional. *}
{assign var=st value=$hadrianLang.a11yStatement}
{assign var=opt value=$hadrian.pages.accessibility.options|default:[]}
{assign var=stStatus value=$opt.stmt_status|default:'partial'}
{assign var=stLimits value=$opt.stmt_limitations|default:''}
{assign var=stMethod value=$opt.stmt_method|default:'self'}
{assign var=stEmail value=$opt.stmt_email|default:''}
{assign var=stEnforce value=$opt.stmt_enforcement|default:''}
{assign var=stPrepared value=$opt.stmt_prepared|default:''}
{assign var=stReviewed value=$opt.stmt_reviewed|default:''}
{assign var=stCompany value=$companyname|default:''|escape}

<div class="a11y-stmt">
    <header class="page-header">
        <p class="page-eyebrow">{$st.eyebrow}</p>
        <h1>{$st.title}</h1>
        <p class="page-subtitle">{$st.intro|replace:'%s':$stCompany}</p>
    </header>

    <section class="card a11y-stmt-card" aria-labelledby="stmtStatus">
        <div class="card-body">
            <h2 id="stmtStatus">{$st.statusHeading}</h2>
            <p>{if $stStatus == 'full'}{$st.statusFull}{elseif $stStatus == 'none'}{$st.statusNone}{else}{$st.statusPartial}{/if}</p>
        </div>
    </section>

    <section class="card a11y-stmt-card" aria-labelledby="stmtMeasures">
        <div class="card-body">
            <h2 id="stmtMeasures">{$st.measuresHeading}</h2>
            <ul>
                <li>{$st.measure1}</li>
                <li>{$st.measure2}</li>
                <li>{$st.measure3}</li>
                <li>{$st.measure4}</li>
                <li>{$st.measure5}</li>
                <li>{$st.measure6}</li>
            </ul>
        </div>
    </section>

    <section class="card a11y-stmt-card" aria-labelledby="stmtLimits">
        <div class="card-body">
            <h2 id="stmtLimits">{$st.limitsHeading}</h2>
            <p>{if $stLimits}{$stLimits|escape}{else}{$st.limitsDefault}{/if}</p>
        </div>
    </section>

    <section class="card a11y-stmt-card" aria-labelledby="stmtMethod">
        <div class="card-body">
            <h2 id="stmtMethod">{$st.methodHeading}</h2>
            <p>{if $stMethod == 'third-party'}{$st.methodThird}{else}{$st.methodSelf}{/if}</p>
        </div>
    </section>

    <section class="card a11y-stmt-card" aria-labelledby="stmtFeedback">
        <div class="card-body">
            <h2 id="stmtFeedback">{$st.feedbackHeading}</h2>
            <p>{$st.feedbackText}</p>
            <ul>
                {if $stEmail}<li>{$st.feedbackEmail|replace:'%s':''}<a href="mailto:{$stEmail|escape}">{$stEmail|escape}</a></li>{/if}
                <li><a href="{$WEB_ROOT}/contact.php">{$st.feedbackContact}</a></li>
                <li><a href="{$WEB_ROOT}/submitticket.php">{$st.feedbackTicket}</a></li>
            </ul>
        </div>
    </section>

    {if $stEnforce}
    <section class="card a11y-stmt-card" aria-labelledby="stmtEnforce">
        <div class="card-body">
            <h2 id="stmtEnforce">{$st.enforceHeading}</h2>
            <p>{$stEnforce|escape}</p>
        </div>
    </section>
    {/if}

    {if $stPrepared || $stReviewed}
    <section class="card a11y-stmt-card" aria-labelledby="stmtDates">
        <div class="card-body">
            <h2 id="stmtDates">{$st.datesHeading}</h2>
            <p>{if $stPrepared}{$st.prepared|replace:'%s':$stPrepared|escape} {/if}{if $stReviewed}{$st.reviewed|replace:'%s':$stReviewed|escape}{/if}</p>
        </div>
    </section>
    {/if}
</div>

<style>{literal}
.a11y-stmt { max-width: var(--w-prose, 760px); margin: 0 auto; }
.a11y-stmt-card { margin-top: 16px; }
.a11y-stmt-card h2 { font-size: var(--text-h4); font-weight: var(--fw-semibold); margin: 0 0 10px; color: var(--color-text-primary); }
.a11y-stmt-card p, .a11y-stmt-card li { color: var(--color-text-secondary); line-height: 1.6; }
.a11y-stmt-card ul { margin: 8px 0 0; padding-left: 20px; }
.a11y-stmt-card li + li { margin-top: 6px; }
{/literal}</style>
