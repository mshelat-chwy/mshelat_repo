set data_date = '2026-05-02';
set start_date = '2026-04-08';
use schema mkt_sponsored_ads_sandbox;

create or replace local temp table tmp_custom_exp_readout_step_1 as
select
    $data_date as data_date,
    --EXP_USER_ID, DEVICE_CATEGORY_VISITOR,
    'ALL' as groupingset, A.EXPERIMENT, A.VARIATION, A.EXP_USER_ID,
   COUNT(a.session_id) as SESSIONS,
    COUNT(CASE WHEN session_has_plp_success THEN a.session_id END) AS plp_success_sessions,
    COUNT(CASE WHEN session_has_pdp_success THEN a.session_id END) AS pdp_success_sessions,
    COUNT(CASE WHEN session_has_atc_success THEN a.session_id END) AS atc_success_sessions,
    COUNT(CASE WHEN session_has_checkout_success THEN a.session_id END) AS checkout_success_sessions,
    COUNT(CASE WHEN session_has_cart_success THEN a.session_id END) AS cart_success_sessions,
    COUNT(CASE WHEN pdp_atc_events > 0 THEN a.session_id END) AS atc_pdp_sessions,
    COUNT(CASE WHEN session_has_pdp_buy_box_success THEN a.session_id END) AS pdp_buybox_sessions,
    COUNT(CASE WHEN session_has_pdp_other_success THEN a.session_id END) AS pdp_carousel_sessions,
    COUNT(CASE WHEN session_has_ata THEN a.session_id END) AS ata_sessions,
    COUNT(CASE WHEN session_has_ata OR session_has_atc THEN a.session_id END) AS ATC_ATA_SESSIONS,
    COUNT(CASE WHEN pdp_ata_events > 0 THEN a.session_id END) AS ata_pdp_sessions,
    COUNT(CASE WHEN pdp_ata_events > 0 OR pdp_atc_events THEN a.session_id END) AS atc_ata_pdp_sessions,
    COUNT(CASE WHEN session_has_cart_event THEN a.session_id END) AS cart_sessions,
    COUNT(CASE WHEN session_has_plp THEN a.session_id END) AS plp_sessions,
    COUNT(CASE WHEN session_has_pdp_view THEN a.session_id END) AS pdp_sessions,
    COUNT(CASE WHEN session_has_atc THEN a.session_id END) AS atc_sessions,
    COUNT(CASE WHEN session_has_checkout THEN a.session_id END) AS checkout_sessions,
    COUNT(CASE WHEN session_has_purchase THEN a.session_id END) AS purchase_sessions,
    COUNT(CASE WHEN autoship_eligible_checkout_session THEN a.session_id END) AS autoship_eligible_checkout_sessions,
    COUNT(CASE WHEN AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSION THEN a.session_id END) AS AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS,
    SUM(units_sold) AS TRANSACTION_QUANTITY,
    SUM(ADS_REVENUE) AS ADS_REVENUE,
    SUM(checkout_uncancelled_orders_placed) AS NOT_CANCELLED_ORDERS,
    SUM(ifnull(ADS_REVENUE,0) + ifnull(ORDER_CCP,0)) AS CCV,
    SUM(ifnull(ORDER_CCP,0)) as ORDER_CCP,
    SUM(MERCH_SALES) AS MERCH_SALES,
 -- (COALESCE((ARRAY_SIZE(ARRAY_DISTINCT(ARRAY_UNION_AGG(checkout_orders_array))) * 0.9), 0)
 --            + COALESCE((SUM(ata_confirmations) * 0.78), 0)) AS TOTAL_PROJECTED_ORDERS_90_DAYS,
    sum(ata_confirmations) as ATA_CONFIRMATIONS,
    SUM(TOTAL_PROJECTED_ORDERS_90_DAYS) AS TOTAL_PROJECTED_ORDERS_90_DAYS,
    SUM(checkout_orders_placed) AS PLACED_ORDERS,
    CASE WHEN MAX(session_has_purchase) then 1 else 0 end AS PURCHASE_FLAG,
    SUM(ADS_CLICKS) AS ADS_CLICKS,
    SUM(ADS_IMPRESSIONS) AS ADS_IMPRESSIONS,
    SUM(ADS_QUANTITY_24H) AS ADS_QUANTITY_24H,
    SUM(ADS_DIRECT_SALES_24H) AS ADS_DIRECT_SALES_24H,
    SUM(GROSS_MARGIN) AS GROSS_MARGIN,
    DIV0NULL(SUM(ADS_IMPRESSIONS),1000) AS ADS_IMPRESSIONS_PER_1000,
    COUNT(CASE WHEN cancel_subscriptions>0 THEN a.session_id END) AS cancelled_subscription_sessions,
    COUNT(CASE WHEN SESSION_HAS_LIST_AS_PAGE_VIEW THEN a.session_id END) AS LIST_AS_SESSIONS,
    COUNT(CASE WHEN SESSION_HAS_MANAGE_AS_PAGE_VIEW THEN a.session_id END) AS MAS_SESSIONS,
    COUNT(CASE WHEN MGMT_ACTIONS>0 THEN a.session_id END) AS MGMT_SESSIONS,
    COUNT(CASE WHEN AS_ORDER_RESCHEDULE_ACTIONS>0 THEN a.session_id END) AS AS_ORDER_RESCHEDULE_SESSIONS,
    COUNT(CASE WHEN ORDER_NOW_CONFIRM_EVENT>0 THEN a.session_id END) AS ORDER_NOW_SESSIONS,
    COUNT(CASE WHEN SKIP_ORDER_CONFIRM_EVENT>0 THEN a.session_id END) AS SKIP_ORDER_SESSIONS,
    COUNT(CASE WHEN SNOOZE_CONFIRM_EVENT>0 THEN a.session_id END) AS SNOOZE_SESSIONS,
    COUNT(CASE WHEN CHANGE_FREQUENCY_EVENT>0 THEN a.session_id END) AS CHANGE_FREQUENCY_SESSIONS,
    COUNT(CASE WHEN ITEM_MGMT_ACTIONS>0 THEN a.session_id END) AS ITEM_MGMT_SESSIONS,
    COUNT(CASE WHEN SUB_SETTING_MGMT_ACTIONS>0 THEN a.session_id END) AS SUB_SETTING_MGMT_SESSIONS,
    SUM(NET_SALES) AS NET_SALES,
    SUM(UNCANCELLED_ORDERS_PLACED) AS UNCANCELLED_ORDERS_PLACED,
    COUNT(CASE WHEN DECREASE_FREQUENCY_EVENT > INCREASE_FREQUENCY_EVENT THEN a.session_id END) AS DECREASE_FREQUENCY_SESSIONS,
    COUNT(CASE WHEN INCREASE_FREQUENCY_EVENT > DECREASE_FREQUENCY_EVENT THEN a.session_id END) AS INCREASE_FREQUENCY_SESSIONS,
    COUNT(CASE WHEN CHANGE_DATE_EVENT > 0 THEN a.session_id END) AS CHANGE_DATE_SESSIONS,
    COUNT(CASE WHEN ITEM_SKIP_ORDER_CHANGE_EVENT > 0 THEN a.session_id END) AS item_skip_order_sessions,
    COUNT(CASE WHEN ITEM_REMOVED_EVENT > 0 THEN a.session_id END) AS item_removed_sessions,
    COUNT(CASE WHEN ftue_session then session_id END) as FTUE_SESSIONS,
    COUNT(CASE WHEN ftue_push_enabled_session THEN session_id END) as FTUE_PUSH_ENABLED_SESSIONS,
    COUNT(CASE WHEN ftue_push_skip_session THEN session_id END) as FTUE_PUSH_SKIP_SESSIONS,
    COUNT(CASE WHEN ftue_push_disabled_session THEN session_id END) as FTUE_PUSH_DISABLED_SESSIONS,
    COUNT(CASE WHEN ftue_push_exit_session then session_id END) as FTUE_PUSH_EXIT_SESSIONS,
    COUNT(CASE WHEN ftue_exit_session THEN session_id END) as FTUE_EXIT_SESSIONS,
    COUNT(CASE WHEN ftue_notification_session THEN session_id END) as FTUE_NOTIFICATION_SESSIONS,
    COUNT(CASE WHEN MAS_BIA_ADD_TO_AUTOSHIP > 0 THEN a.session_id END) AS MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS,
    COUNT(CASE WHEN MAS_ITEM_QUANTITY_CHANGE_EVENT > 0 THEN a.session_id END) AS MAS_ITEM_QUANTITY_CHANGE_SESSIONS,
    COUNT(CASE WHEN MAS_PROMO_APPLIED_EVENT > 0 THEN a.session_id END) AS MAS_PROMO_APPLIED_SESSIONS,
    COUNT(CASE WHEN MAS_REPLACE_ITEM_EVENT > 0 THEN a.session_id END) AS MAS_REPLACE_ITEM_SESSIONS,
    COUNT(CASE WHEN MAS_ADD_MORE_ITEM_EVENT > 0 THEN a.session_id END) AS MAS_ADD_MORE_ITEM_SESSIONS,
    COUNT(CASE WHEN SESSION_HAS_MANAGE_AS_PAGE_VIEW AND MGMT_ACTIONS = 0 THEN a.session_id END) AS MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS,
    COUNT(CASE WHEN HOME_PAGE_CLICK_HITS>0 THEN a.session_id END) as HOME_PAGE_CLICKS_SESSIONS,
    COUNT(CASE WHEN BARK_BAR_IMPRESSIONS>0 THEN a.session_id END) as BARK_BAR_IMPRESSION_SESSIONS,
    COUNT(CASE WHEN BARK_BAR_CLICKS>0 THEN a.session_id END) as BARK_BAR_CLICK_SESSIONS,
    SUM(CHECKOUT_CANCELLED_ORDERS) AS CHECKOUT_CANCELLED_ORDERS,
    COUNT(CASE WHEN ORDER_NOW_EDIT_PAYMENT_EVENT>0 THEN a.session_id END) as ORDER_NOW_EDIT_PAYMENT_SESSIONS,
    COUNT(CASE WHEN ORDER_NOW_EDIT_ADDRESS_EVENT>0 THEN a.session_id END) as ORDER_NOW_EDIT_ADDRESS_SESSIONS,
    COUNT(CASE WHEN HOME_PAGE_VIEWS>0 THEN a.session_id END) AS HOMEPAGE_SESSIONS,
    SUM(ifnull(PET_PROFILE_CREATION_COUNT,0)) AS PET_PROFILE_CREATION_COUNT,
    SUM(ifnull(PET_PHOTO_UPLOAD_COUNT,0)) AS PET_PHOTO_UPLOAD_COUNT,
    COUNT(CASE WHEN CWAV_PAGEVIEWS>0 THEN a.session_id END) AS CWAV_SESSIONS,
    COUNT(CASE WHEN CAREPLUS_PAGEVIEWS>0 THEN a.session_id END) AS CAREPLUS_SESSIONS,
    COUNT(CASE WHEN PET_PORTAL_PAGEVIEWS>0 THEN a.session_id END) AS PET_PORTAL_SESSIONS,
    SUM(ifnull(HOMEPAGE_DISTINCT_WIDGETS,0)) AS HOMEPAGE_DISTINCT_WIDGETS,
    SUM(ifnull(HOMEPAGE_BRAND_PM_IMPRESSIONS,0)) AS HOMEPAGE_BRAND_PM_IMPRESSIONS,
    COUNT(CASE WHEN UNCANCELLED_FIRST_APP_ORDERS_PLACED>0 THEN a.session_id END) AS UNCANCELLED_FIRST_APP_ORDERS_PLACED,
    count(case when home_bounce_session_flag then session_id end) as HOME_BOUNCE_SESSIONS,
    count(case when home_exit_session_flag then session_id end) as HOME_EXIT_SESSIONS,
    case when max(new_to_app_order_flag) then 1 else 0 end as NEW_TO_APP_ORDER_FLAG
from ecom_sandbox.vw_exp_session_metrics a
join ecom_sandbox.exp_active_experiments b
    on a.experiment=b.experiment
        and a.session_date >=b.start_date
        and a.session_date <= $data_date
        and b.data_date=$data_date
where a.experiment = '2026_04_DISCOVERY_SEARCH_REDIRECT_REMOVALS'
    and a.session_date >= $start_date
    and a.session_id in (
        select distinct session_id from discovery_sandbox.prd_f_d_expr_search_metrics_optimizely
        where session_date >= $start_date
            and search_term in (select distinct search_term from tmp_brand_redirect_search_terms)
    )
group by all
order by 3;


CREATE OR REPLACE LOCAL TEMP TABLE TEMP_TEST_METRICS_PERCENTILES AS
SELECT
  PERCENTILE_CONT(0.02) WITHIN GROUP (ORDER BY CCV) AS CCV_PERCENTILE_LOWER,
  PERCENTILE_CONT(0.98) WITHIN GROUP (ORDER BY CCV) AS CCV_PERCENTILE_UPPER,
  PERCENTILE_CONT(0.02) WITHIN GROUP (ORDER BY ORDER_CCP) AS ORDER_CCP_PERCENTILE_LOWER,
  PERCENTILE_CONT(0.98) WITHIN GROUP (ORDER BY ORDER_CCP) AS ORDER_CCP_PERCENTILE_UPPER,
  PERCENTILE_CONT(0.98) WITHIN GROUP (ORDER BY MERCH_SALES) AS MERCH_SALES_PERCENTILE_UPPER,
  PERCENTILE_CONT(0.98) WITHIN GROUP (ORDER BY PLACED_ORDERS) AS PLACED_ORDERS_PERCENTILE_UPPER,
  PERCENTILE_CONT(0.98) WITHIN GROUP (ORDER BY NOT_CANCELLED_ORDERS) AS NOT_CANCELLED_ORDERS_PERCENTILE_UPPER,
  PERCENTILE_CONT(0.98) WITHIN GROUP (ORDER BY TRANSACTION_QUANTITY) AS TRANSACTION_QUANTITY_PERCENTILE_UPPER,
  PERCENTILE_CONT(0.98) WITHIN GROUP (ORDER BY ADS_REVENUE) AS ADS_REVENUE_PERCENTILE_UPPER,
  PERCENTILE_CONT(0.98) WITHIN GROUP (ORDER BY TOTAL_PROJECTED_ORDERS_90_DAYS) AS TOTAL_PROJECTED_ORDERS_90_DAYS_PERCENTILE_UPPER,
  PERCENTILE_CONT(0.98) WITHIN GROUP (ORDER BY PURCHASE_SESSIONS) AS PURCHASE_SESSIONS_PERCENTILE_UPPER,
  EXPERIMENT
FROM tmp_custom_exp_readout_step_1
GROUP BY EXPERIMENT
;


CREATE OR REPLACE LOCAL TEMP TABLE TEMP_TEST_METRICS_OUTLIER_FILTERED AS
SELECT data_date,
     a.ADS_CLICKS,
     a.ADS_DIRECT_SALES_24H,
     a.ADS_IMPRESSIONS,
     a.ADS_IMPRESSIONS_PER_1000,
     a.ADS_QUANTITY_24H,
     CASE
  WHEN ADS_REVENUE > b.ADS_REVENUE_PERCENTILE_UPPER THEN b.ADS_REVENUE_PERCENTILE_UPPER
  ELSE ADS_REVENUE
END AS ADS_REVENUE,
     a.AS_ORDER_RESCHEDULE_SESSIONS,
     a.ATA_CONFIRMATIONS,
     a.ATA_PDP_SESSIONS,
     a.ATA_SESSIONS,
     a.ATC_ATA_PDP_SESSIONS,
     a.ATC_ATA_SESSIONS,
     a.ATC_PDP_SESSIONS,
     a.ATC_SESSIONS,
     a.ATC_SUCCESS_SESSIONS,
     a.AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS,
     a.AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS,
     a.BARK_BAR_CLICK_SESSIONS,
     a.BARK_BAR_IMPRESSION_SESSIONS,
     a.CANCELLED_SUBSCRIPTION_SESSIONS,
     a.CAREPLUS_SESSIONS,
     a.CART_SESSIONS,
     a.CART_SUCCESS_SESSIONS,
     CASE
  WHEN CCV < b.CCV_PERCENTILE_LOWER THEN b.CCV_PERCENTILE_LOWER
  WHEN CCV > b.CCV_PERCENTILE_UPPER THEN b.CCV_PERCENTILE_UPPER
  ELSE CCV
END AS CCV,
     a.CHANGE_DATE_SESSIONS,
     a.CHANGE_FREQUENCY_SESSIONS,
     a.CHECKOUT_CANCELLED_ORDERS,
     a.CHECKOUT_SESSIONS,
     a.CHECKOUT_SUCCESS_SESSIONS,
     a.CWAV_SESSIONS,
     a.DECREASE_FREQUENCY_SESSIONS,
     a.EXPERIMENT,
     a.EXP_USER_ID,
     a.FTUE_EXIT_SESSIONS,
     a.FTUE_NOTIFICATION_SESSIONS,
     a.FTUE_PUSH_DISABLED_SESSIONS,
     a.FTUE_PUSH_ENABLED_SESSIONS,
     a.FTUE_PUSH_EXIT_SESSIONS,
     a.FTUE_PUSH_SKIP_SESSIONS,
     a.FTUE_SESSIONS,
     a.GROSS_MARGIN,
     a.HOMEPAGE_BRAND_PM_IMPRESSIONS,
     a.HOMEPAGE_DISTINCT_WIDGETS,
     a.HOMEPAGE_SESSIONS,
     a.HOME_BOUNCE_SESSIONS,
     a.HOME_EXIT_SESSIONS,
     a.HOME_PAGE_CLICKS_SESSIONS,
     a.INCREASE_FREQUENCY_SESSIONS,
     a.ITEM_MGMT_SESSIONS,
     a.ITEM_REMOVED_SESSIONS,
     a.ITEM_SKIP_ORDER_SESSIONS,
     a.LIST_AS_SESSIONS,
     a.MAS_ADD_MORE_ITEM_SESSIONS,
     a.MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS,
     a.MAS_ITEM_QUANTITY_CHANGE_SESSIONS,
     a.MAS_PROMO_APPLIED_SESSIONS,
     a.MAS_REPLACE_ITEM_SESSIONS,
     a.MAS_SESSIONS,
     a.MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS,
     CASE
  WHEN MERCH_SALES > b.MERCH_SALES_PERCENTILE_UPPER THEN b.MERCH_SALES_PERCENTILE_UPPER
  ELSE MERCH_SALES
END AS MERCH_SALES,
     a.MGMT_SESSIONS,
     a.NET_SALES,
     a.NEW_TO_APP_ORDER_FLAG,
     CASE
  WHEN NOT_CANCELLED_ORDERS > b.NOT_CANCELLED_ORDERS_PERCENTILE_UPPER THEN b.NOT_CANCELLED_ORDERS_PERCENTILE_UPPER
  ELSE NOT_CANCELLED_ORDERS
END AS NOT_CANCELLED_ORDERS,
     CASE
  WHEN ORDER_CCP < b.ORDER_CCP_PERCENTILE_LOWER THEN b.ORDER_CCP_PERCENTILE_LOWER
  WHEN ORDER_CCP > b.ORDER_CCP_PERCENTILE_UPPER THEN b.ORDER_CCP_PERCENTILE_UPPER
  ELSE ORDER_CCP
END AS ORDER_CCP,
     a.ORDER_NOW_EDIT_ADDRESS_SESSIONS,
     a.ORDER_NOW_EDIT_PAYMENT_SESSIONS,
     a.ORDER_NOW_SESSIONS,
     a.PDP_BUYBOX_SESSIONS,
     a.PDP_CAROUSEL_SESSIONS,
     a.PDP_SESSIONS,
     a.PDP_SUCCESS_SESSIONS,
     a.PET_PHOTO_UPLOAD_COUNT,
     a.PET_PORTAL_SESSIONS,
     a.PET_PROFILE_CREATION_COUNT,
     CASE
  WHEN PLACED_ORDERS > b.PLACED_ORDERS_PERCENTILE_UPPER THEN b.PLACED_ORDERS_PERCENTILE_UPPER
  ELSE PLACED_ORDERS
END AS PLACED_ORDERS,
     a.PLP_SESSIONS,
     a.PLP_SUCCESS_SESSIONS,
     a.PURCHASE_FLAG,
     CASE
  WHEN PURCHASE_SESSIONS > b.PURCHASE_SESSIONS_PERCENTILE_UPPER THEN b.PURCHASE_SESSIONS_PERCENTILE_UPPER
  ELSE PURCHASE_SESSIONS
END AS PURCHASE_SESSIONS,
     a.SESSIONS,
     a.SKIP_ORDER_SESSIONS,
     a.SNOOZE_SESSIONS,
     a.SUB_SETTING_MGMT_SESSIONS,
     CASE
  WHEN TOTAL_PROJECTED_ORDERS_90_DAYS > b.TOTAL_PROJECTED_ORDERS_90_DAYS_PERCENTILE_UPPER THEN b.TOTAL_PROJECTED_ORDERS_90_DAYS_PERCENTILE_UPPER
  ELSE TOTAL_PROJECTED_ORDERS_90_DAYS
END AS TOTAL_PROJECTED_ORDERS_90_DAYS,
     CASE
  WHEN TRANSACTION_QUANTITY > b.TRANSACTION_QUANTITY_PERCENTILE_UPPER THEN b.TRANSACTION_QUANTITY_PERCENTILE_UPPER
  ELSE TRANSACTION_QUANTITY
END AS TRANSACTION_QUANTITY,
     a.UNCANCELLED_FIRST_APP_ORDERS_PLACED,
     a.UNCANCELLED_ORDERS_PLACED,
     a.VARIATION
FROM tmp_custom_exp_readout_step_1 a
LEFT JOIN TEMP_TEST_METRICS_PERCENTILES b
  ON a.EXPERIMENT = b.EXPERIMENT
;

create or replace local temporary table TEMP_TEST_METRICS_level_1 as
with visitor_counts as (
    select data_date, experiment, variation,
        count(distinct exp_user_id) as visitorcount
    from TEMP_TEST_METRICS_OUTLIER_FILTERED
    group by data_date, experiment, variation
)
select
  $data_date  data_date
    , 'ALL' as groupingset_name
    , m.EXPERIMENT
    , m.VARIATION
    , max(v.visitorcount) as visitor_count
    , COALESCE(DIV0NULL(sum(m.PLP_SUCCESS_SESSIONS),visitor_count), 0) as AVG_PLP_SUCCESS_SESSIONS
    , COALESCE(DIV0NULL(sum(m.PLP_SESSIONS),visitor_count), 0) as AVG_PLP_SESSIONS
    , sum(m.PLP_SUCCESS_SESSIONS) as SUM_PLP_SUCCESS_SESSIONS
    , sum(m.PLP_SESSIONS) as SUM_PLP_SESSIONS
    , count(distinct m.PLP_SUCCESS_SESSIONS) as COUNT_DISTINCT_PLP_SUCCESS_SESSIONS
    , count(distinct m.PLP_SESSIONS) as COUNT_DISTINCT_PLP_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.PLP_SUCCESS_SESSIONS,2)) - (visitor_count * power((sum(m.PLP_SUCCESS_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_PLP_SUCCESS_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.PLP_SESSIONS,2)) - (visitor_count * power((sum(m.PLP_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_PLP_SESSIONS
    , case when visitor_count > 1 then (sum(m.PLP_SUCCESS_SESSIONS * m.PLP_SESSIONS) - (visitor_count * (sum(m.PLP_SUCCESS_SESSIONS) / visitor_count) * (sum(m.PLP_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_PLP_SUCCESS_RATE
    , stddev(m.PLP_SUCCESS_SESSIONS) as STDDEV_PLP_SUCCESS_SESSIONS
    , stddev(m.PLP_SESSIONS) as STDDEV_PLP_SESSIONS
    , COALESCE(DIV0NULL(sum(m.PDP_SUCCESS_SESSIONS),visitor_count), 0) as AVG_PDP_SUCCESS_SESSIONS
    , COALESCE(DIV0NULL(sum(m.PDP_SESSIONS),visitor_count), 0) as AVG_PDP_SESSIONS
    , sum(m.PDP_SUCCESS_SESSIONS) as SUM_PDP_SUCCESS_SESSIONS
    , sum(m.PDP_SESSIONS) as SUM_PDP_SESSIONS
    , count(distinct m.PDP_SUCCESS_SESSIONS) as COUNT_DISTINCT_PDP_SUCCESS_SESSIONS
    , count(distinct m.PDP_SESSIONS) as COUNT_DISTINCT_PDP_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.PDP_SUCCESS_SESSIONS,2)) - (visitor_count * power((sum(m.PDP_SUCCESS_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_PDP_SUCCESS_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.PDP_SESSIONS,2)) - (visitor_count * power((sum(m.PDP_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_PDP_SESSIONS
    , case when visitor_count > 1 then (sum(m.PDP_SUCCESS_SESSIONS * m.PDP_SESSIONS) - (visitor_count * (sum(m.PDP_SUCCESS_SESSIONS) / visitor_count) * (sum(m.PDP_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_PDP_SUCCESS_RATE
    , stddev(m.PDP_SUCCESS_SESSIONS) as STDDEV_PDP_SUCCESS_SESSIONS
    , stddev(m.PDP_SESSIONS) as STDDEV_PDP_SESSIONS
    , COALESCE(DIV0NULL(sum(m.ATC_SUCCESS_SESSIONS),visitor_count), 0) as AVG_ATC_SUCCESS_SESSIONS
    , COALESCE(DIV0NULL(sum(m.ATC_SESSIONS),visitor_count), 0) as AVG_ATC_SESSIONS
    , sum(m.ATC_SUCCESS_SESSIONS) as SUM_ATC_SUCCESS_SESSIONS
    , sum(m.ATC_SESSIONS) as SUM_ATC_SESSIONS
    , count(distinct m.ATC_SUCCESS_SESSIONS) as COUNT_DISTINCT_ATC_SUCCESS_SESSIONS
    , count(distinct m.ATC_SESSIONS) as COUNT_DISTINCT_ATC_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.ATC_SUCCESS_SESSIONS,2)) - (visitor_count * power((sum(m.ATC_SUCCESS_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ATC_SUCCESS_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.ATC_SESSIONS,2)) - (visitor_count * power((sum(m.ATC_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ATC_SESSIONS
    , case when visitor_count > 1 then (sum(m.ATC_SUCCESS_SESSIONS * m.ATC_SESSIONS) - (visitor_count * (sum(m.ATC_SUCCESS_SESSIONS) / visitor_count) * (sum(m.ATC_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_ATC_SUCCESS_RATE
    , stddev(m.ATC_SUCCESS_SESSIONS) as STDDEV_ATC_SUCCESS_SESSIONS
    , stddev(m.ATC_SESSIONS) as STDDEV_ATC_SESSIONS
    , COALESCE(DIV0NULL(sum(m.CHECKOUT_SUCCESS_SESSIONS),visitor_count), 0) as AVG_CHECKOUT_SUCCESS_SESSIONS
    , COALESCE(DIV0NULL(sum(m.CHECKOUT_SESSIONS),visitor_count), 0) as AVG_CHECKOUT_SESSIONS
    , sum(m.CHECKOUT_SUCCESS_SESSIONS) as SUM_CHECKOUT_SUCCESS_SESSIONS
    , sum(m.CHECKOUT_SESSIONS) as SUM_CHECKOUT_SESSIONS
    , count(distinct m.CHECKOUT_SUCCESS_SESSIONS) as COUNT_DISTINCT_CHECKOUT_SUCCESS_SESSIONS
    , count(distinct m.CHECKOUT_SESSIONS) as COUNT_DISTINCT_CHECKOUT_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.CHECKOUT_SUCCESS_SESSIONS,2)) - (visitor_count * power((sum(m.CHECKOUT_SUCCESS_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_CHECKOUT_SUCCESS_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.CHECKOUT_SESSIONS,2)) - (visitor_count * power((sum(m.CHECKOUT_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_CHECKOUT_SESSIONS
    , case when visitor_count > 1 then (sum(m.CHECKOUT_SUCCESS_SESSIONS * m.CHECKOUT_SESSIONS) - (visitor_count * (sum(m.CHECKOUT_SUCCESS_SESSIONS) / visitor_count) * (sum(m.CHECKOUT_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_CHECKOUT_SUCCESS_RATE
    , stddev(m.CHECKOUT_SUCCESS_SESSIONS) as STDDEV_CHECKOUT_SUCCESS_SESSIONS
    , stddev(m.CHECKOUT_SESSIONS) as STDDEV_CHECKOUT_SESSIONS
    , case when visitor_count > 1 then (sum(m.CHECKOUT_SESSIONS * m.ATC_SESSIONS) - (visitor_count * (sum(m.CHECKOUT_SESSIONS) / visitor_count) * (sum(m.ATC_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_CART_ABANDONMENT_RATE
    , COALESCE(DIV0NULL(sum(m.CART_SUCCESS_SESSIONS),visitor_count), 0) as AVG_CART_SUCCESS_SESSIONS
    , COALESCE(DIV0NULL(sum(m.CART_SESSIONS),visitor_count), 0) as AVG_CART_SESSIONS
    , sum(m.CART_SUCCESS_SESSIONS) as SUM_CART_SUCCESS_SESSIONS
    , sum(m.CART_SESSIONS) as SUM_CART_SESSIONS
    , count(distinct m.CART_SUCCESS_SESSIONS) as COUNT_DISTINCT_CART_SUCCESS_SESSIONS
    , count(distinct m.CART_SESSIONS) as COUNT_DISTINCT_CART_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.CART_SUCCESS_SESSIONS,2)) - (visitor_count * power((sum(m.CART_SUCCESS_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_CART_SUCCESS_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.CART_SESSIONS,2)) - (visitor_count * power((sum(m.CART_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_CART_SESSIONS
    , case when visitor_count > 1 then (sum(m.CART_SUCCESS_SESSIONS * m.CART_SESSIONS) - (visitor_count * (sum(m.CART_SUCCESS_SESSIONS) / visitor_count) * (sum(m.CART_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_CART_PAGE_SUCCESS_RATE
    , stddev(m.CART_SUCCESS_SESSIONS) as STDDEV_CART_SUCCESS_SESSIONS
    , stddev(m.CART_SESSIONS) as STDDEV_CART_SESSIONS
    , COALESCE(DIV0NULL(sum(m.PLACED_ORDERS),visitor_count), 0) as AVG_PLACED_ORDERS
    , COALESCE(DIV0NULL(sum(m.SESSIONS),visitor_count), 0) as AVG_SESSIONS
    , sum(m.PLACED_ORDERS) as SUM_PLACED_ORDERS
    , sum(m.SESSIONS) as SUM_SESSIONS
    , count(distinct m.PLACED_ORDERS) as COUNT_DISTINCT_PLACED_ORDERS
    , count(distinct m.SESSIONS) as COUNT_DISTINCT_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.PLACED_ORDERS,2)) - (visitor_count * power((sum(m.PLACED_ORDERS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_PLACED_ORDERS
    , case when visitor_count > 1 then (sum(power(m.SESSIONS,2)) - (visitor_count * power((sum(m.SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_SESSIONS
    , case when visitor_count > 1 then (sum(m.PLACED_ORDERS * m.SESSIONS) - (visitor_count * (sum(m.PLACED_ORDERS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_CVR
    , stddev(m.PLACED_ORDERS) as STDDEV_PLACED_ORDERS
    , stddev(m.SESSIONS) as STDDEV_SESSIONS
    , COALESCE(DIV0NULL(sum(m.PURCHASE_SESSIONS),visitor_count), 0) as AVG_PURCHASE_SESSIONS
    , sum(m.PURCHASE_SESSIONS) as SUM_PURCHASE_SESSIONS
    , count(distinct m.PURCHASE_SESSIONS) as COUNT_DISTINCT_PURCHASE_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.PURCHASE_SESSIONS,2)) - (visitor_count * power((sum(m.PURCHASE_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_PURCHASE_SESSIONS
    , case when visitor_count > 1 then (sum(m.PURCHASE_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.PURCHASE_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_UNIQUE_CVR
    , stddev(m.PURCHASE_SESSIONS) as STDDEV_PURCHASE_SESSIONS
    , COALESCE(DIV0NULL(sum(m.MERCH_SALES),visitor_count), 0) as AVG_MERCH_SALES
    , COALESCE(DIV0NULL(sum(m.TRANSACTION_QUANTITY),visitor_count), 0) as AVG_TRANSACTION_QUANTITY
    , sum(m.MERCH_SALES) as SUM_MERCH_SALES
    , sum(m.TRANSACTION_QUANTITY) as SUM_TRANSACTION_QUANTITY
    , count(distinct m.MERCH_SALES) as COUNT_DISTINCT_MERCH_SALES
    , count(distinct m.TRANSACTION_QUANTITY) as COUNT_DISTINCT_TRANSACTION_QUANTITY
    , case when visitor_count > 1 then (sum(power(m.MERCH_SALES,2)) - (visitor_count * power((sum(m.MERCH_SALES) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_MERCH_SALES
    , case when visitor_count > 1 then (sum(power(m.TRANSACTION_QUANTITY,2)) - (visitor_count * power((sum(m.TRANSACTION_QUANTITY) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_TRANSACTION_QUANTITY
    , case when visitor_count > 1 then (sum(m.MERCH_SALES * m.TRANSACTION_QUANTITY) - (visitor_count * (sum(m.MERCH_SALES) / visitor_count) * (sum(m.TRANSACTION_QUANTITY) / visitor_count))) / (visitor_count - 1) else 0 end as COV_MERCH_ASP
    , stddev(m.MERCH_SALES) as STDDEV_MERCH_SALES
    , stddev(m.TRANSACTION_QUANTITY) as STDDEV_TRANSACTION_QUANTITY
    , COALESCE(DIV0NULL(sum(m.NOT_CANCELLED_ORDERS),visitor_count), 0) as AVG_NOT_CANCELLED_ORDERS
    , sum(m.NOT_CANCELLED_ORDERS) as SUM_NOT_CANCELLED_ORDERS
    , count(distinct m.NOT_CANCELLED_ORDERS) as COUNT_DISTINCT_NOT_CANCELLED_ORDERS
    , case when visitor_count > 1 then (sum(power(m.NOT_CANCELLED_ORDERS,2)) - (visitor_count * power((sum(m.NOT_CANCELLED_ORDERS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_NOT_CANCELLED_ORDERS
    , case when visitor_count > 1 then (sum(m.MERCH_SALES * m.NOT_CANCELLED_ORDERS) - (visitor_count * (sum(m.MERCH_SALES) / visitor_count) * (sum(m.NOT_CANCELLED_ORDERS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_AOV_MERCH_SALES
    , stddev(m.NOT_CANCELLED_ORDERS) as STDDEV_NOT_CANCELLED_ORDERS
    , case when visitor_count > 1 then (sum(m.TRANSACTION_QUANTITY * m.NOT_CANCELLED_ORDERS) - (visitor_count * (sum(m.TRANSACTION_QUANTITY) / visitor_count) * (sum(m.NOT_CANCELLED_ORDERS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_NET_UPO
    , COALESCE(DIV0NULL(sum(m.ATC_ATA_SESSIONS),visitor_count), 0) as AVG_ATC_ATA_SESSIONS
    , sum(m.ATC_ATA_SESSIONS) as SUM_ATC_ATA_SESSIONS
    , count(distinct m.ATC_ATA_SESSIONS) as COUNT_DISTINCT_ATC_ATA_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.ATC_ATA_SESSIONS,2)) - (visitor_count * power((sum(m.ATC_ATA_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ATC_ATA_SESSIONS
    , case when visitor_count > 1 then (sum(m.ATC_ATA_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.ATC_ATA_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_OVERALL_ATC_ATA_RATE
    , stddev(m.ATC_ATA_SESSIONS) as STDDEV_ATC_ATA_SESSIONS
    , case when visitor_count > 1 then (sum(m.ATC_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.ATC_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_OVERALL_ATC_RATE
    , COALESCE(DIV0NULL(sum(m.ATA_SESSIONS),visitor_count), 0) as AVG_ATA_SESSIONS
    , sum(m.ATA_SESSIONS) as SUM_ATA_SESSIONS
    , count(distinct m.ATA_SESSIONS) as COUNT_DISTINCT_ATA_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.ATA_SESSIONS,2)) - (visitor_count * power((sum(m.ATA_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ATA_SESSIONS
    , case when visitor_count > 1 then (sum(m.ATA_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.ATA_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_OVERALL_ATA_RATE
    , stddev(m.ATA_SESSIONS) as STDDEV_ATA_SESSIONS
    , COALESCE(DIV0NULL(sum(m.ATC_ATA_PDP_SESSIONS),visitor_count), 0) as AVG_ATC_ATA_PDP_SESSIONS
    , sum(m.ATC_ATA_PDP_SESSIONS) as SUM_ATC_ATA_PDP_SESSIONS
    , count(distinct m.ATC_ATA_PDP_SESSIONS) as COUNT_DISTINCT_ATC_ATA_PDP_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.ATC_ATA_PDP_SESSIONS,2)) - (visitor_count * power((sum(m.ATC_ATA_PDP_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ATC_ATA_PDP_SESSIONS
    , case when visitor_count > 1 then (sum(m.ATC_ATA_PDP_SESSIONS * m.PDP_SESSIONS) - (visitor_count * (sum(m.ATC_ATA_PDP_SESSIONS) / visitor_count) * (sum(m.PDP_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_PDP_ATC_ATA_RATE
    , stddev(m.ATC_ATA_PDP_SESSIONS) as STDDEV_ATC_ATA_PDP_SESSIONS
    , COALESCE(DIV0NULL(sum(m.ATC_PDP_SESSIONS),visitor_count), 0) as AVG_ATC_PDP_SESSIONS
    , sum(m.ATC_PDP_SESSIONS) as SUM_ATC_PDP_SESSIONS
    , count(distinct m.ATC_PDP_SESSIONS) as COUNT_DISTINCT_ATC_PDP_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.ATC_PDP_SESSIONS,2)) - (visitor_count * power((sum(m.ATC_PDP_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ATC_PDP_SESSIONS
    , case when visitor_count > 1 then (sum(m.ATC_PDP_SESSIONS * m.PDP_SESSIONS) - (visitor_count * (sum(m.ATC_PDP_SESSIONS) / visitor_count) * (sum(m.PDP_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_PDP_ATC_RATE
    , stddev(m.ATC_PDP_SESSIONS) as STDDEV_ATC_PDP_SESSIONS
    , COALESCE(DIV0NULL(sum(m.ATA_PDP_SESSIONS),visitor_count), 0) as AVG_ATA_PDP_SESSIONS
    , sum(m.ATA_PDP_SESSIONS) as SUM_ATA_PDP_SESSIONS
    , count(distinct m.ATA_PDP_SESSIONS) as COUNT_DISTINCT_ATA_PDP_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.ATA_PDP_SESSIONS,2)) - (visitor_count * power((sum(m.ATA_PDP_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ATA_PDP_SESSIONS
    , case when visitor_count > 1 then (sum(m.ATA_PDP_SESSIONS * m.PDP_SESSIONS) - (visitor_count * (sum(m.ATA_PDP_SESSIONS) / visitor_count) * (sum(m.PDP_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_PDP_ATA_RATE
    , stddev(m.ATA_PDP_SESSIONS) as STDDEV_ATA_PDP_SESSIONS
    , COALESCE(DIV0NULL(sum(m.PDP_BUYBOX_SESSIONS),visitor_count), 0) as AVG_PDP_BUYBOX_SESSIONS
    , sum(m.PDP_BUYBOX_SESSIONS) as SUM_PDP_BUYBOX_SESSIONS
    , count(distinct m.PDP_BUYBOX_SESSIONS) as COUNT_DISTINCT_PDP_BUYBOX_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.PDP_BUYBOX_SESSIONS,2)) - (visitor_count * power((sum(m.PDP_BUYBOX_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_PDP_BUYBOX_SESSIONS
    , case when visitor_count > 1 then (sum(m.PDP_BUYBOX_SESSIONS * m.PDP_SESSIONS) - (visitor_count * (sum(m.PDP_BUYBOX_SESSIONS) / visitor_count) * (sum(m.PDP_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_PDP_BUYBOX_RATE
    , stddev(m.PDP_BUYBOX_SESSIONS) as STDDEV_PDP_BUYBOX_SESSIONS
    , COALESCE(DIV0NULL(sum(m.PDP_CAROUSEL_SESSIONS),visitor_count), 0) as AVG_PDP_CAROUSEL_SESSIONS
    , sum(m.PDP_CAROUSEL_SESSIONS) as SUM_PDP_CAROUSEL_SESSIONS
    , count(distinct m.PDP_CAROUSEL_SESSIONS) as COUNT_DISTINCT_PDP_CAROUSEL_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.PDP_CAROUSEL_SESSIONS,2)) - (visitor_count * power((sum(m.PDP_CAROUSEL_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_PDP_CAROUSEL_SESSIONS
    , case when visitor_count > 1 then (sum(m.PDP_CAROUSEL_SESSIONS * m.PDP_SESSIONS) - (visitor_count * (sum(m.PDP_CAROUSEL_SESSIONS) / visitor_count) * (sum(m.PDP_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_PDP_CAROUSEL_RATE
    , stddev(m.PDP_CAROUSEL_SESSIONS) as STDDEV_PDP_CAROUSEL_SESSIONS
    , COALESCE(DIV0NULL(sum(m.ADS_REVENUE),visitor_count), 0) as AVG_ADS_REVENUE
    , sum(m.ADS_REVENUE) as SUM_ADS_REVENUE
    , count(distinct m.ADS_REVENUE) as COUNT_DISTINCT_ADS_REVENUE
    , case when visitor_count > 1 then (sum(power(m.ADS_REVENUE,2)) - (visitor_count * power((sum(m.ADS_REVENUE) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ADS_REVENUE
    , case when visitor_count > 1 then (sum(m.ADS_REVENUE * m.SESSIONS) - (visitor_count * (sum(m.ADS_REVENUE) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_ADS_REVENUE_PER_SESSION
    , stddev(m.ADS_REVENUE) as STDDEV_ADS_REVENUE
    , NULL as COV_ADS_REVENUE_PER_VISITOR
    , COALESCE(DIV0NULL(sum(m.PURCHASE_FLAG),visitor_count), 0) as AVG_PURCHASE_FLAG
    , sum(m.PURCHASE_FLAG) as SUM_PURCHASE_FLAG
    , count(distinct m.PURCHASE_FLAG) as COUNT_DISTINCT_PURCHASE_FLAG
    , case when visitor_count > 1 then (sum(power(m.PURCHASE_FLAG,2)) - (visitor_count * power((sum(m.PURCHASE_FLAG) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_PURCHASE_FLAG
    , NULL as COV_UNIQUE_VISITOR_CVR
    , stddev(m.PURCHASE_FLAG) as STDDEV_PURCHASE_FLAG
    , COALESCE(DIV0NULL(sum(m.TOTAL_PROJECTED_ORDERS_90_DAYS),visitor_count), 0) as AVG_TOTAL_PROJECTED_ORDERS_90_DAYS
    , sum(m.TOTAL_PROJECTED_ORDERS_90_DAYS) as SUM_TOTAL_PROJECTED_ORDERS_90_DAYS
    , count(distinct m.TOTAL_PROJECTED_ORDERS_90_DAYS) as COUNT_DISTINCT_TOTAL_PROJECTED_ORDERS_90_DAYS
    , case when visitor_count > 1 then (sum(power(m.TOTAL_PROJECTED_ORDERS_90_DAYS,2)) - (visitor_count * power((sum(m.TOTAL_PROJECTED_ORDERS_90_DAYS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_TOTAL_PROJECTED_ORDERS_90_DAYS
    , case when visitor_count > 1 then (sum(m.TOTAL_PROJECTED_ORDERS_90_DAYS * m.SESSIONS) - (visitor_count * (sum(m.TOTAL_PROJECTED_ORDERS_90_DAYS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_CVR_ATA_RATE
    , stddev(m.TOTAL_PROJECTED_ORDERS_90_DAYS) as STDDEV_TOTAL_PROJECTED_ORDERS_90_DAYS
    , COALESCE(DIV0NULL(sum(m.CCV),visitor_count), 0) as AVG_CCV
    , sum(m.CCV) as SUM_CCV
    , count(distinct m.CCV) as COUNT_DISTINCT_CCV
    , case when visitor_count > 1 then (sum(power(m.CCV,2)) - (visitor_count * power((sum(m.CCV) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_CCV
    , NULL as COV_CCV
    , stddev(m.CCV) as STDDEV_CCV
    , case when visitor_count > 1 then (sum(m.CCV * m.SESSIONS) - (visitor_count * (sum(m.CCV) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_CCV_PER_SESSION
    , case when visitor_count > 1 then (sum(m.MERCH_SALES * m.SESSIONS) - (visitor_count * (sum(m.MERCH_SALES) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_MERCH_SALES_PER_SESSION
    , COALESCE(DIV0NULL(sum(m.GROSS_MARGIN),visitor_count), 0) as AVG_GROSS_MARGIN
    , sum(m.GROSS_MARGIN) as SUM_GROSS_MARGIN
    , count(distinct m.GROSS_MARGIN) as COUNT_DISTINCT_GROSS_MARGIN
    , case when visitor_count > 1 then (sum(power(m.GROSS_MARGIN,2)) - (visitor_count * power((sum(m.GROSS_MARGIN) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_GROSS_MARGIN
    , case when visitor_count > 1 then (sum(m.GROSS_MARGIN * m.SESSIONS) - (visitor_count * (sum(m.GROSS_MARGIN) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_GROSS_MARGIN_PER_SESSION
    , stddev(m.GROSS_MARGIN) as STDDEV_GROSS_MARGIN
    , NULL as COV_MERCH_SALES_PER_VISITOR
    , NULL as COV_ORDER_PER_VISITOR
    , COALESCE(DIV0NULL(sum(m.AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS),visitor_count), 0) as AVG_AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS
    , COALESCE(DIV0NULL(sum(m.AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS),visitor_count), 0) as AVG_AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS
    , sum(m.AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS) as SUM_AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS
    , sum(m.AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS) as SUM_AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS
    , count(distinct m.AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS) as COUNT_DISTINCT_AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS
    , count(distinct m.AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS) as COUNT_DISTINCT_AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS,2)) - (visitor_count * power((sum(m.AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS,2)) - (visitor_count * power((sum(m.AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS
    , case when visitor_count > 1 then (sum(m.AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS * m.AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS) - (visitor_count * (sum(m.AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS) / visitor_count) * (sum(m.AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_AUTOSHIP_CHECKOUT_SUCCESS_RATE
    , stddev(m.AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS) as STDDEV_AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS
    , stddev(m.AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS) as STDDEV_AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS
    , COALESCE(DIV0NULL(sum(m.ADS_CLICKS),visitor_count), 0) as AVG_ADS_CLICKS
    , COALESCE(DIV0NULL(sum(m.ADS_IMPRESSIONS),visitor_count), 0) as AVG_ADS_IMPRESSIONS
    , sum(m.ADS_CLICKS) as SUM_ADS_CLICKS
    , sum(m.ADS_IMPRESSIONS) as SUM_ADS_IMPRESSIONS
    , count(distinct m.ADS_CLICKS) as COUNT_DISTINCT_ADS_CLICKS
    , count(distinct m.ADS_IMPRESSIONS) as COUNT_DISTINCT_ADS_IMPRESSIONS
    , case when visitor_count > 1 then (sum(power(m.ADS_CLICKS,2)) - (visitor_count * power((sum(m.ADS_CLICKS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ADS_CLICKS
    , case when visitor_count > 1 then (sum(power(m.ADS_IMPRESSIONS,2)) - (visitor_count * power((sum(m.ADS_IMPRESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ADS_IMPRESSIONS
    , case when visitor_count > 1 then (sum(m.ADS_CLICKS * m.ADS_IMPRESSIONS) - (visitor_count * (sum(m.ADS_CLICKS) / visitor_count) * (sum(m.ADS_IMPRESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_AD_CTR
    , stddev(m.ADS_CLICKS) as STDDEV_ADS_CLICKS
    , stddev(m.ADS_IMPRESSIONS) as STDDEV_ADS_IMPRESSIONS
    , COALESCE(DIV0NULL(sum(m.ADS_DIRECT_SALES_24H),visitor_count), 0) as AVG_ADS_DIRECT_SALES_24H
    , sum(m.ADS_DIRECT_SALES_24H) as SUM_ADS_DIRECT_SALES_24H
    , count(distinct m.ADS_DIRECT_SALES_24H) as COUNT_DISTINCT_ADS_DIRECT_SALES_24H
    , case when visitor_count > 1 then (sum(power(m.ADS_DIRECT_SALES_24H,2)) - (visitor_count * power((sum(m.ADS_DIRECT_SALES_24H) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ADS_DIRECT_SALES_24H
    , case when visitor_count > 1 then (sum(m.ADS_DIRECT_SALES_24H * m.ADS_REVENUE) - (visitor_count * (sum(m.ADS_DIRECT_SALES_24H) / visitor_count) * (sum(m.ADS_REVENUE) / visitor_count))) / (visitor_count - 1) else 0 end as COV_AD_ROAS_24H
    , stddev(m.ADS_DIRECT_SALES_24H) as STDDEV_ADS_DIRECT_SALES_24H
    , COALESCE(DIV0NULL(sum(m.ADS_QUANTITY_24H),visitor_count), 0) as AVG_ADS_QUANTITY_24H
    , sum(m.ADS_QUANTITY_24H) as SUM_ADS_QUANTITY_24H
    , count(distinct m.ADS_QUANTITY_24H) as COUNT_DISTINCT_ADS_QUANTITY_24H
    , case when visitor_count > 1 then (sum(power(m.ADS_QUANTITY_24H,2)) - (visitor_count * power((sum(m.ADS_QUANTITY_24H) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ADS_QUANTITY_24H
    , case when visitor_count > 1 then (sum(m.ADS_QUANTITY_24H * m.ADS_CLICKS) - (visitor_count * (sum(m.ADS_QUANTITY_24H) / visitor_count) * (sum(m.ADS_CLICKS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_AD_CVR_24H
    , stddev(m.ADS_QUANTITY_24H) as STDDEV_ADS_QUANTITY_24H
    , COALESCE(DIV0NULL(sum(m.ADS_IMPRESSIONS_PER_1000),visitor_count), 0) as AVG_ADS_IMPRESSIONS_PER_1000
    , sum(m.ADS_IMPRESSIONS_PER_1000) as SUM_ADS_IMPRESSIONS_PER_1000
    , count(distinct m.ADS_IMPRESSIONS_PER_1000) as COUNT_DISTINCT_ADS_IMPRESSIONS_PER_1000
    , case when visitor_count > 1 then (sum(power(m.ADS_IMPRESSIONS_PER_1000,2)) - (visitor_count * power((sum(m.ADS_IMPRESSIONS_PER_1000) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ADS_IMPRESSIONS_PER_1000
    , case when visitor_count > 1 then (sum(m.ADS_REVENUE * m.ADS_IMPRESSIONS_PER_1000) - (visitor_count * (sum(m.ADS_REVENUE) / visitor_count) * (sum(m.ADS_IMPRESSIONS_PER_1000) / visitor_count))) / (visitor_count - 1) else 0 end as COV_AD_ECPM
    , stddev(m.ADS_IMPRESSIONS_PER_1000) as STDDEV_ADS_IMPRESSIONS_PER_1000
    , case when visitor_count > 1 then (sum(m.ADS_REVENUE * m.ADS_CLICKS) - (visitor_count * (sum(m.ADS_REVENUE) / visitor_count) * (sum(m.ADS_CLICKS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_AD_CPC
    , case when visitor_count > 1 then (sum(m.ADS_IMPRESSIONS * m.SESSIONS) - (visitor_count * (sum(m.ADS_IMPRESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_AD_IMPRESSIONS_PER_SESSION
    , NULL as COV_ADS_IMPRESSIONS_PER_VISITOR
    , case when visitor_count > 1 then (sum(m.ADS_CLICKS * m.SESSIONS) - (visitor_count * (sum(m.ADS_CLICKS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_AD_CLICKS_PER_SESSION
    , NULL as COV_AD_CLICKS_PER_VISITOR
    , NULL as COV_SESSIONS_PER_VISITOR
    , case when visitor_count > 1 then (sum(m.PLP_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.PLP_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_PLP_RATE
    , case when visitor_count > 1 then (sum(m.PDP_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.PDP_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_PDP_RATE
    , case when visitor_count > 1 then (sum(m.ATC_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.ATC_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_ATC_RATE
    , case when visitor_count > 1 then (sum(m.CHECKOUT_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.CHECKOUT_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_CHECKOUT_RATE
    , COALESCE(DIV0NULL(sum(m.CANCELLED_SUBSCRIPTION_SESSIONS),visitor_count), 0) as AVG_CANCELLED_SUBSCRIPTION_SESSIONS
    , sum(m.CANCELLED_SUBSCRIPTION_SESSIONS) as SUM_CANCELLED_SUBSCRIPTION_SESSIONS
    , count(distinct m.CANCELLED_SUBSCRIPTION_SESSIONS) as COUNT_DISTINCT_CANCELLED_SUBSCRIPTION_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.CANCELLED_SUBSCRIPTION_SESSIONS,2)) - (visitor_count * power((sum(m.CANCELLED_SUBSCRIPTION_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_CANCELLED_SUBSCRIPTION_SESSIONS
    , case when visitor_count > 1 then (sum(m.CANCELLED_SUBSCRIPTION_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.CANCELLED_SUBSCRIPTION_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_AUTOSHIP_SUBSCRIPTION_CANCELLATION_RATE
    , stddev(m.CANCELLED_SUBSCRIPTION_SESSIONS) as STDDEV_CANCELLED_SUBSCRIPTION_SESSIONS
    , COALESCE(DIV0NULL(sum(m.LIST_AS_SESSIONS),visitor_count), 0) as AVG_LIST_AS_SESSIONS
    , sum(m.LIST_AS_SESSIONS) as SUM_LIST_AS_SESSIONS
    , count(distinct m.LIST_AS_SESSIONS) as COUNT_DISTINCT_LIST_AS_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.LIST_AS_SESSIONS,2)) - (visitor_count * power((sum(m.LIST_AS_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_LIST_AS_SESSIONS
    , case when visitor_count > 1 then (sum(m.LIST_AS_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.LIST_AS_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_LIST_AS_PAGE_VISIT_RATE
    , stddev(m.LIST_AS_SESSIONS) as STDDEV_LIST_AS_SESSIONS
    , COALESCE(DIV0NULL(sum(m.MAS_SESSIONS),visitor_count), 0) as AVG_MAS_SESSIONS
    , sum(m.MAS_SESSIONS) as SUM_MAS_SESSIONS
    , count(distinct m.MAS_SESSIONS) as COUNT_DISTINCT_MAS_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.MAS_SESSIONS,2)) - (visitor_count * power((sum(m.MAS_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_MAS_SESSIONS
    , case when visitor_count > 1 then (sum(m.MAS_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.MAS_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_MANAGE_AS_PAGE_VISIT_RATE
    , stddev(m.MAS_SESSIONS) as STDDEV_MAS_SESSIONS
    , COALESCE(DIV0NULL(sum(m.MGMT_SESSIONS),visitor_count), 0) as AVG_MGMT_SESSIONS
    , sum(m.MGMT_SESSIONS) as SUM_MGMT_SESSIONS
    , count(distinct m.MGMT_SESSIONS) as COUNT_DISTINCT_MGMT_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.MGMT_SESSIONS,2)) - (visitor_count * power((sum(m.MGMT_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_MGMT_SESSIONS
    , case when visitor_count > 1 then (sum(m.MGMT_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.MGMT_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_TOTAL_MGMT_RATE
    , stddev(m.MGMT_SESSIONS) as STDDEV_MGMT_SESSIONS
    , COALESCE(DIV0NULL(sum(m.AS_ORDER_RESCHEDULE_SESSIONS),visitor_count), 0) as AVG_AS_ORDER_RESCHEDULE_SESSIONS
    , sum(m.AS_ORDER_RESCHEDULE_SESSIONS) as SUM_AS_ORDER_RESCHEDULE_SESSIONS
    , count(distinct m.AS_ORDER_RESCHEDULE_SESSIONS) as COUNT_DISTINCT_AS_ORDER_RESCHEDULE_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.AS_ORDER_RESCHEDULE_SESSIONS,2)) - (visitor_count * power((sum(m.AS_ORDER_RESCHEDULE_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_AS_ORDER_RESCHEDULE_SESSIONS
    , case when visitor_count > 1 then (sum(m.AS_ORDER_RESCHEDULE_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.AS_ORDER_RESCHEDULE_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_AS_ORDER_RESCHEDULING_RATE
    , stddev(m.AS_ORDER_RESCHEDULE_SESSIONS) as STDDEV_AS_ORDER_RESCHEDULE_SESSIONS
    , COALESCE(DIV0NULL(sum(m.ORDER_NOW_SESSIONS),visitor_count), 0) as AVG_ORDER_NOW_SESSIONS
    , sum(m.ORDER_NOW_SESSIONS) as SUM_ORDER_NOW_SESSIONS
    , count(distinct m.ORDER_NOW_SESSIONS) as COUNT_DISTINCT_ORDER_NOW_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.ORDER_NOW_SESSIONS,2)) - (visitor_count * power((sum(m.ORDER_NOW_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ORDER_NOW_SESSIONS
    , case when visitor_count > 1 then (sum(m.ORDER_NOW_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.ORDER_NOW_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_ORDER_NOW_RATE
    , stddev(m.ORDER_NOW_SESSIONS) as STDDEV_ORDER_NOW_SESSIONS
    , COALESCE(DIV0NULL(sum(m.SKIP_ORDER_SESSIONS),visitor_count), 0) as AVG_SKIP_ORDER_SESSIONS
    , sum(m.SKIP_ORDER_SESSIONS) as SUM_SKIP_ORDER_SESSIONS
    , count(distinct m.SKIP_ORDER_SESSIONS) as COUNT_DISTINCT_SKIP_ORDER_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.SKIP_ORDER_SESSIONS,2)) - (visitor_count * power((sum(m.SKIP_ORDER_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_SKIP_ORDER_SESSIONS
    , case when visitor_count > 1 then (sum(m.SKIP_ORDER_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.SKIP_ORDER_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_SKIP_ORDER_RATE
    , stddev(m.SKIP_ORDER_SESSIONS) as STDDEV_SKIP_ORDER_SESSIONS
    , COALESCE(DIV0NULL(sum(m.SNOOZE_SESSIONS),visitor_count), 0) as AVG_SNOOZE_SESSIONS
    , sum(m.SNOOZE_SESSIONS) as SUM_SNOOZE_SESSIONS
    , count(distinct m.SNOOZE_SESSIONS) as COUNT_DISTINCT_SNOOZE_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.SNOOZE_SESSIONS,2)) - (visitor_count * power((sum(m.SNOOZE_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_SNOOZE_SESSIONS
    , case when visitor_count > 1 then (sum(m.SNOOZE_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.SNOOZE_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_SNOOZE_RATE
    , stddev(m.SNOOZE_SESSIONS) as STDDEV_SNOOZE_SESSIONS
    , COALESCE(DIV0NULL(sum(m.CHANGE_FREQUENCY_SESSIONS),visitor_count), 0) as AVG_CHANGE_FREQUENCY_SESSIONS
    , sum(m.CHANGE_FREQUENCY_SESSIONS) as SUM_CHANGE_FREQUENCY_SESSIONS
    , count(distinct m.CHANGE_FREQUENCY_SESSIONS) as COUNT_DISTINCT_CHANGE_FREQUENCY_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.CHANGE_FREQUENCY_SESSIONS,2)) - (visitor_count * power((sum(m.CHANGE_FREQUENCY_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_CHANGE_FREQUENCY_SESSIONS
    , case when visitor_count > 1 then (sum(m.CHANGE_FREQUENCY_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.CHANGE_FREQUENCY_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_AS_FREQUENCY_CHANGE_RATE
    , stddev(m.CHANGE_FREQUENCY_SESSIONS) as STDDEV_CHANGE_FREQUENCY_SESSIONS
    , COALESCE(DIV0NULL(sum(m.ITEM_MGMT_SESSIONS),visitor_count), 0) as AVG_ITEM_MGMT_SESSIONS
    , sum(m.ITEM_MGMT_SESSIONS) as SUM_ITEM_MGMT_SESSIONS
    , count(distinct m.ITEM_MGMT_SESSIONS) as COUNT_DISTINCT_ITEM_MGMT_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.ITEM_MGMT_SESSIONS,2)) - (visitor_count * power((sum(m.ITEM_MGMT_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ITEM_MGMT_SESSIONS
    , case when visitor_count > 1 then (sum(m.ITEM_MGMT_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.ITEM_MGMT_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_ITEM_MANAGEMENT_RATE
    , stddev(m.ITEM_MGMT_SESSIONS) as STDDEV_ITEM_MGMT_SESSIONS
    , COALESCE(DIV0NULL(sum(m.SUB_SETTING_MGMT_SESSIONS),visitor_count), 0) as AVG_SUB_SETTING_MGMT_SESSIONS
    , sum(m.SUB_SETTING_MGMT_SESSIONS) as SUM_SUB_SETTING_MGMT_SESSIONS
    , count(distinct m.SUB_SETTING_MGMT_SESSIONS) as COUNT_DISTINCT_SUB_SETTING_MGMT_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.SUB_SETTING_MGMT_SESSIONS,2)) - (visitor_count * power((sum(m.SUB_SETTING_MGMT_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_SUB_SETTING_MGMT_SESSIONS
    , case when visitor_count > 1 then (sum(m.SUB_SETTING_MGMT_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.SUB_SETTING_MGMT_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_SUBSCRIPTIONS_SETTINGS_MANAGEMENT_RATE
    , stddev(m.SUB_SETTING_MGMT_SESSIONS) as STDDEV_SUB_SETTING_MGMT_SESSIONS
    , COALESCE(DIV0NULL(sum(m.NET_SALES),visitor_count), 0) as AVG_NET_SALES
    , COALESCE(DIV0NULL(sum(m.UNCANCELLED_ORDERS_PLACED),visitor_count), 0) as AVG_UNCANCELLED_ORDERS_PLACED
    , sum(m.NET_SALES) as SUM_NET_SALES
    , sum(m.UNCANCELLED_ORDERS_PLACED) as SUM_UNCANCELLED_ORDERS_PLACED
    , count(distinct m.NET_SALES) as COUNT_DISTINCT_NET_SALES
    , count(distinct m.UNCANCELLED_ORDERS_PLACED) as COUNT_DISTINCT_UNCANCELLED_ORDERS_PLACED
    , case when visitor_count > 1 then (sum(power(m.NET_SALES,2)) - (visitor_count * power((sum(m.NET_SALES) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_NET_SALES
    , case when visitor_count > 1 then (sum(power(m.UNCANCELLED_ORDERS_PLACED,2)) - (visitor_count * power((sum(m.UNCANCELLED_ORDERS_PLACED) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_UNCANCELLED_ORDERS_PLACED
    , case when visitor_count > 1 then (sum(m.NET_SALES * m.UNCANCELLED_ORDERS_PLACED) - (visitor_count * (sum(m.NET_SALES) / visitor_count) * (sum(m.UNCANCELLED_ORDERS_PLACED) / visitor_count))) / (visitor_count - 1) else 0 end as COV_NET_AOV
    , stddev(m.NET_SALES) as STDDEV_NET_SALES
    , stddev(m.UNCANCELLED_ORDERS_PLACED) as STDDEV_UNCANCELLED_ORDERS_PLACED
    , case when visitor_count > 1 then (sum(m.MERCH_SALES * m.PLACED_ORDERS) - (visitor_count * (sum(m.MERCH_SALES) / visitor_count) * (sum(m.PLACED_ORDERS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_MERCH_AOV
    , case when visitor_count > 1 then (sum(m.UNCANCELLED_ORDERS_PLACED * m.SESSIONS) - (visitor_count * (sum(m.UNCANCELLED_ORDERS_PLACED) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_NET_CVR
    , COALESCE(DIV0NULL(sum(m.CHANGE_DATE_SESSIONS),visitor_count), 0) as AVG_CHANGE_DATE_SESSIONS
    , sum(m.CHANGE_DATE_SESSIONS) as SUM_CHANGE_DATE_SESSIONS
    , count(distinct m.CHANGE_DATE_SESSIONS) as COUNT_DISTINCT_CHANGE_DATE_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.CHANGE_DATE_SESSIONS,2)) - (visitor_count * power((sum(m.CHANGE_DATE_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_CHANGE_DATE_SESSIONS
    , case when visitor_count > 1 then (sum(m.CHANGE_DATE_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.CHANGE_DATE_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_CHANGE_DATE_RATE
    , stddev(m.CHANGE_DATE_SESSIONS) as STDDEV_CHANGE_DATE_SESSIONS
    , COALESCE(DIV0NULL(sum(m.INCREASE_FREQUENCY_SESSIONS),visitor_count), 0) as AVG_INCREASE_FREQUENCY_SESSIONS
    , sum(m.INCREASE_FREQUENCY_SESSIONS) as SUM_INCREASE_FREQUENCY_SESSIONS
    , count(distinct m.INCREASE_FREQUENCY_SESSIONS) as COUNT_DISTINCT_INCREASE_FREQUENCY_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.INCREASE_FREQUENCY_SESSIONS,2)) - (visitor_count * power((sum(m.INCREASE_FREQUENCY_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_INCREASE_FREQUENCY_SESSIONS
    , case when visitor_count > 1 then (sum(m.INCREASE_FREQUENCY_SESSIONS * m.CHANGE_FREQUENCY_SESSIONS) - (visitor_count * (sum(m.INCREASE_FREQUENCY_SESSIONS) / visitor_count) * (sum(m.CHANGE_FREQUENCY_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_INCREASE_FREQUENCY_RATE
    , stddev(m.INCREASE_FREQUENCY_SESSIONS) as STDDEV_INCREASE_FREQUENCY_SESSIONS
    , COALESCE(DIV0NULL(sum(m.DECREASE_FREQUENCY_SESSIONS),visitor_count), 0) as AVG_DECREASE_FREQUENCY_SESSIONS
    , sum(m.DECREASE_FREQUENCY_SESSIONS) as SUM_DECREASE_FREQUENCY_SESSIONS
    , count(distinct m.DECREASE_FREQUENCY_SESSIONS) as COUNT_DISTINCT_DECREASE_FREQUENCY_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.DECREASE_FREQUENCY_SESSIONS,2)) - (visitor_count * power((sum(m.DECREASE_FREQUENCY_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_DECREASE_FREQUENCY_SESSIONS
    , case when visitor_count > 1 then (sum(m.DECREASE_FREQUENCY_SESSIONS * m.CHANGE_FREQUENCY_SESSIONS) - (visitor_count * (sum(m.DECREASE_FREQUENCY_SESSIONS) / visitor_count) * (sum(m.CHANGE_FREQUENCY_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_DECREASE_FREQUENCY_RATE
    , stddev(m.DECREASE_FREQUENCY_SESSIONS) as STDDEV_DECREASE_FREQUENCY_SESSIONS
    , COALESCE(DIV0NULL(sum(m.ITEM_REMOVED_SESSIONS),visitor_count), 0) as AVG_ITEM_REMOVED_SESSIONS
    , sum(m.ITEM_REMOVED_SESSIONS) as SUM_ITEM_REMOVED_SESSIONS
    , count(distinct m.ITEM_REMOVED_SESSIONS) as COUNT_DISTINCT_ITEM_REMOVED_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.ITEM_REMOVED_SESSIONS,2)) - (visitor_count * power((sum(m.ITEM_REMOVED_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ITEM_REMOVED_SESSIONS
    , case when visitor_count > 1 then (sum(m.ITEM_REMOVED_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.ITEM_REMOVED_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_REMOVE_ITEM_RATE
    , stddev(m.ITEM_REMOVED_SESSIONS) as STDDEV_ITEM_REMOVED_SESSIONS
    , COALESCE(DIV0NULL(sum(m.ITEM_SKIP_ORDER_SESSIONS),visitor_count), 0) as AVG_ITEM_SKIP_ORDER_SESSIONS
    , sum(m.ITEM_SKIP_ORDER_SESSIONS) as SUM_ITEM_SKIP_ORDER_SESSIONS
    , count(distinct m.ITEM_SKIP_ORDER_SESSIONS) as COUNT_DISTINCT_ITEM_SKIP_ORDER_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.ITEM_SKIP_ORDER_SESSIONS,2)) - (visitor_count * power((sum(m.ITEM_SKIP_ORDER_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ITEM_SKIP_ORDER_SESSIONS
    , case when visitor_count > 1 then (sum(m.ITEM_SKIP_ORDER_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.ITEM_SKIP_ORDER_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_SKIP_ITEM_RATE
    , stddev(m.ITEM_SKIP_ORDER_SESSIONS) as STDDEV_ITEM_SKIP_ORDER_SESSIONS
    , COALESCE(DIV0NULL(sum(m.ATA_CONFIRMATIONS),visitor_count), 0) as AVG_ATA_CONFIRMATIONS
    , sum(m.ATA_CONFIRMATIONS) as SUM_ATA_CONFIRMATIONS
    , count(distinct m.ATA_CONFIRMATIONS) as COUNT_DISTINCT_ATA_CONFIRMATIONS
    , case when visitor_count > 1 then (sum(power(m.ATA_CONFIRMATIONS,2)) - (visitor_count * power((sum(m.ATA_CONFIRMATIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ATA_CONFIRMATIONS
    , case when visitor_count > 1 then (sum(m.ATA_CONFIRMATIONS * m.SESSIONS) - (visitor_count * (sum(m.ATA_CONFIRMATIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_ATA_CONFIRMATION_PER_SESSION
    , stddev(m.ATA_CONFIRMATIONS) as STDDEV_ATA_CONFIRMATIONS
    , NULL as COV_ATA_CONFIRMATION_PER_VISITOR
    , COALESCE(DIV0NULL(sum(m.FTUE_PUSH_ENABLED_SESSIONS),visitor_count), 0) as AVG_FTUE_PUSH_ENABLED_SESSIONS
    , COALESCE(DIV0NULL(sum(m.FTUE_SESSIONS),visitor_count), 0) as AVG_FTUE_SESSIONS
    , sum(m.FTUE_PUSH_ENABLED_SESSIONS) as SUM_FTUE_PUSH_ENABLED_SESSIONS
    , sum(m.FTUE_SESSIONS) as SUM_FTUE_SESSIONS
    , count(distinct m.FTUE_PUSH_ENABLED_SESSIONS) as COUNT_DISTINCT_FTUE_PUSH_ENABLED_SESSIONS
    , count(distinct m.FTUE_SESSIONS) as COUNT_DISTINCT_FTUE_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.FTUE_PUSH_ENABLED_SESSIONS,2)) - (visitor_count * power((sum(m.FTUE_PUSH_ENABLED_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_FTUE_PUSH_ENABLED_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.FTUE_SESSIONS,2)) - (visitor_count * power((sum(m.FTUE_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_FTUE_SESSIONS
    , case when visitor_count > 1 then (sum(m.FTUE_PUSH_ENABLED_SESSIONS * m.FTUE_SESSIONS) - (visitor_count * (sum(m.FTUE_PUSH_ENABLED_SESSIONS) / visitor_count) * (sum(m.FTUE_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_APP_FTUE_PUSH_ENABLEMENT_RATE
    , stddev(m.FTUE_PUSH_ENABLED_SESSIONS) as STDDEV_FTUE_PUSH_ENABLED_SESSIONS
    , stddev(m.FTUE_SESSIONS) as STDDEV_FTUE_SESSIONS
    , COALESCE(DIV0NULL(sum(m.FTUE_PUSH_SKIP_SESSIONS),visitor_count), 0) as AVG_FTUE_PUSH_SKIP_SESSIONS
    , sum(m.FTUE_PUSH_SKIP_SESSIONS) as SUM_FTUE_PUSH_SKIP_SESSIONS
    , count(distinct m.FTUE_PUSH_SKIP_SESSIONS) as COUNT_DISTINCT_FTUE_PUSH_SKIP_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.FTUE_PUSH_SKIP_SESSIONS,2)) - (visitor_count * power((sum(m.FTUE_PUSH_SKIP_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_FTUE_PUSH_SKIP_SESSIONS
    , case when visitor_count > 1 then (sum(m.FTUE_PUSH_SKIP_SESSIONS * m.FTUE_SESSIONS) - (visitor_count * (sum(m.FTUE_PUSH_SKIP_SESSIONS) / visitor_count) * (sum(m.FTUE_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_APP_FTUE_PUSH_SKIP_RATE
    , stddev(m.FTUE_PUSH_SKIP_SESSIONS) as STDDEV_FTUE_PUSH_SKIP_SESSIONS
    , COALESCE(DIV0NULL(sum(m.FTUE_PUSH_DISABLED_SESSIONS),visitor_count), 0) as AVG_FTUE_PUSH_DISABLED_SESSIONS
    , sum(m.FTUE_PUSH_DISABLED_SESSIONS) as SUM_FTUE_PUSH_DISABLED_SESSIONS
    , count(distinct m.FTUE_PUSH_DISABLED_SESSIONS) as COUNT_DISTINCT_FTUE_PUSH_DISABLED_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.FTUE_PUSH_DISABLED_SESSIONS,2)) - (visitor_count * power((sum(m.FTUE_PUSH_DISABLED_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_FTUE_PUSH_DISABLED_SESSIONS
    , case when visitor_count > 1 then (sum(m.FTUE_PUSH_DISABLED_SESSIONS * m.FTUE_SESSIONS) - (visitor_count * (sum(m.FTUE_PUSH_DISABLED_SESSIONS) / visitor_count) * (sum(m.FTUE_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_APP_FTUE_PUSH_DISABLEMENT_RATE
    , stddev(m.FTUE_PUSH_DISABLED_SESSIONS) as STDDEV_FTUE_PUSH_DISABLED_SESSIONS
    , COALESCE(DIV0NULL(sum(m.FTUE_PUSH_EXIT_SESSIONS),visitor_count), 0) as AVG_FTUE_PUSH_EXIT_SESSIONS
    , COALESCE(DIV0NULL(sum(m.FTUE_NOTIFICATION_SESSIONS),visitor_count), 0) as AVG_FTUE_NOTIFICATION_SESSIONS
    , sum(m.FTUE_PUSH_EXIT_SESSIONS) as SUM_FTUE_PUSH_EXIT_SESSIONS
    , sum(m.FTUE_NOTIFICATION_SESSIONS) as SUM_FTUE_NOTIFICATION_SESSIONS
    , count(distinct m.FTUE_PUSH_EXIT_SESSIONS) as COUNT_DISTINCT_FTUE_PUSH_EXIT_SESSIONS
    , count(distinct m.FTUE_NOTIFICATION_SESSIONS) as COUNT_DISTINCT_FTUE_NOTIFICATION_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.FTUE_PUSH_EXIT_SESSIONS,2)) - (visitor_count * power((sum(m.FTUE_PUSH_EXIT_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_FTUE_PUSH_EXIT_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.FTUE_NOTIFICATION_SESSIONS,2)) - (visitor_count * power((sum(m.FTUE_NOTIFICATION_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_FTUE_NOTIFICATION_SESSIONS
    , case when visitor_count > 1 then (sum(m.FTUE_PUSH_EXIT_SESSIONS * m.FTUE_NOTIFICATION_SESSIONS) - (visitor_count * (sum(m.FTUE_PUSH_EXIT_SESSIONS) / visitor_count) * (sum(m.FTUE_NOTIFICATION_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_APP_FTUE_PUSH_EXIT_RATE
    , stddev(m.FTUE_PUSH_EXIT_SESSIONS) as STDDEV_FTUE_PUSH_EXIT_SESSIONS
    , stddev(m.FTUE_NOTIFICATION_SESSIONS) as STDDEV_FTUE_NOTIFICATION_SESSIONS
    , COALESCE(DIV0NULL(sum(m.FTUE_EXIT_SESSIONS),visitor_count), 0) as AVG_FTUE_EXIT_SESSIONS
    , sum(m.FTUE_EXIT_SESSIONS) as SUM_FTUE_EXIT_SESSIONS
    , count(distinct m.FTUE_EXIT_SESSIONS) as COUNT_DISTINCT_FTUE_EXIT_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.FTUE_EXIT_SESSIONS,2)) - (visitor_count * power((sum(m.FTUE_EXIT_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_FTUE_EXIT_SESSIONS
    , case when visitor_count > 1 then (sum(m.FTUE_EXIT_SESSIONS * m.FTUE_SESSIONS) - (visitor_count * (sum(m.FTUE_EXIT_SESSIONS) / visitor_count) * (sum(m.FTUE_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_APP_FTUE_EXIT_RATE
    , stddev(m.FTUE_EXIT_SESSIONS) as STDDEV_FTUE_EXIT_SESSIONS
    , COALESCE(DIV0NULL(sum(m.MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS),visitor_count), 0) as AVG_MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS
    , sum(m.MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS) as SUM_MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS
    , count(distinct m.MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS) as COUNT_DISTINCT_MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS,2)) - (visitor_count * power((sum(m.MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS
    , case when visitor_count > 1 then (sum(m.MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_MAS_BIA_ATA_RATE
    , stddev(m.MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS) as STDDEV_MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS
    , COALESCE(DIV0NULL(sum(m.MAS_ITEM_QUANTITY_CHANGE_SESSIONS),visitor_count), 0) as AVG_MAS_ITEM_QUANTITY_CHANGE_SESSIONS
    , sum(m.MAS_ITEM_QUANTITY_CHANGE_SESSIONS) as SUM_MAS_ITEM_QUANTITY_CHANGE_SESSIONS
    , count(distinct m.MAS_ITEM_QUANTITY_CHANGE_SESSIONS) as COUNT_DISTINCT_MAS_ITEM_QUANTITY_CHANGE_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.MAS_ITEM_QUANTITY_CHANGE_SESSIONS,2)) - (visitor_count * power((sum(m.MAS_ITEM_QUANTITY_CHANGE_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_MAS_ITEM_QUANTITY_CHANGE_SESSIONS
    , case when visitor_count > 1 then (sum(m.MAS_ITEM_QUANTITY_CHANGE_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.MAS_ITEM_QUANTITY_CHANGE_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_MAS_ITEM_QUANTITY_CHANGE_RATE
    , stddev(m.MAS_ITEM_QUANTITY_CHANGE_SESSIONS) as STDDEV_MAS_ITEM_QUANTITY_CHANGE_SESSIONS
    , COALESCE(DIV0NULL(sum(m.MAS_PROMO_APPLIED_SESSIONS),visitor_count), 0) as AVG_MAS_PROMO_APPLIED_SESSIONS
    , sum(m.MAS_PROMO_APPLIED_SESSIONS) as SUM_MAS_PROMO_APPLIED_SESSIONS
    , count(distinct m.MAS_PROMO_APPLIED_SESSIONS) as COUNT_DISTINCT_MAS_PROMO_APPLIED_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.MAS_PROMO_APPLIED_SESSIONS,2)) - (visitor_count * power((sum(m.MAS_PROMO_APPLIED_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_MAS_PROMO_APPLIED_SESSIONS
    , case when visitor_count > 1 then (sum(m.MAS_PROMO_APPLIED_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.MAS_PROMO_APPLIED_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_MAS_PROMO_APPLICATION_RATE
    , stddev(m.MAS_PROMO_APPLIED_SESSIONS) as STDDEV_MAS_PROMO_APPLIED_SESSIONS
    , COALESCE(DIV0NULL(sum(m.MAS_REPLACE_ITEM_SESSIONS),visitor_count), 0) as AVG_MAS_REPLACE_ITEM_SESSIONS
    , sum(m.MAS_REPLACE_ITEM_SESSIONS) as SUM_MAS_REPLACE_ITEM_SESSIONS
    , count(distinct m.MAS_REPLACE_ITEM_SESSIONS) as COUNT_DISTINCT_MAS_REPLACE_ITEM_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.MAS_REPLACE_ITEM_SESSIONS,2)) - (visitor_count * power((sum(m.MAS_REPLACE_ITEM_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_MAS_REPLACE_ITEM_SESSIONS
    , case when visitor_count > 1 then (sum(m.MAS_REPLACE_ITEM_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.MAS_REPLACE_ITEM_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_MAS_REPLACE_ITEM_RATE
    , stddev(m.MAS_REPLACE_ITEM_SESSIONS) as STDDEV_MAS_REPLACE_ITEM_SESSIONS
    , COALESCE(DIV0NULL(sum(m.MAS_ADD_MORE_ITEM_SESSIONS),visitor_count), 0) as AVG_MAS_ADD_MORE_ITEM_SESSIONS
    , sum(m.MAS_ADD_MORE_ITEM_SESSIONS) as SUM_MAS_ADD_MORE_ITEM_SESSIONS
    , count(distinct m.MAS_ADD_MORE_ITEM_SESSIONS) as COUNT_DISTINCT_MAS_ADD_MORE_ITEM_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.MAS_ADD_MORE_ITEM_SESSIONS,2)) - (visitor_count * power((sum(m.MAS_ADD_MORE_ITEM_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_MAS_ADD_MORE_ITEM_SESSIONS
    , case when visitor_count > 1 then (sum(m.MAS_ADD_MORE_ITEM_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.MAS_ADD_MORE_ITEM_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_MAS_ADD_MORE_ITEMS_RATE
    , stddev(m.MAS_ADD_MORE_ITEM_SESSIONS) as STDDEV_MAS_ADD_MORE_ITEM_SESSIONS
    , COALESCE(DIV0NULL(sum(m.MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS),visitor_count), 0) as AVG_MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS
    , sum(m.MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS) as SUM_MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS
    , count(distinct m.MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS) as COUNT_DISTINCT_MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS,2)) - (visitor_count * power((sum(m.MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS
    , case when visitor_count > 1 then (sum(m.MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS * m.MAS_SESSIONS) - (visitor_count * (sum(m.MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS) / visitor_count) * (sum(m.MAS_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_MAS_NO_MGMT_SESSION_RATE
    , stddev(m.MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS) as STDDEV_MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS
    , COALESCE(DIV0NULL(sum(m.BARK_BAR_CLICK_SESSIONS),visitor_count), 0) as AVG_BARK_BAR_CLICK_SESSIONS
    , COALESCE(DIV0NULL(sum(m.BARK_BAR_IMPRESSION_SESSIONS),visitor_count), 0) as AVG_BARK_BAR_IMPRESSION_SESSIONS
    , sum(m.BARK_BAR_CLICK_SESSIONS) as SUM_BARK_BAR_CLICK_SESSIONS
    , sum(m.BARK_BAR_IMPRESSION_SESSIONS) as SUM_BARK_BAR_IMPRESSION_SESSIONS
    , count(distinct m.BARK_BAR_CLICK_SESSIONS) as COUNT_DISTINCT_BARK_BAR_CLICK_SESSIONS
    , count(distinct m.BARK_BAR_IMPRESSION_SESSIONS) as COUNT_DISTINCT_BARK_BAR_IMPRESSION_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.BARK_BAR_CLICK_SESSIONS,2)) - (visitor_count * power((sum(m.BARK_BAR_CLICK_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_BARK_BAR_CLICK_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.BARK_BAR_IMPRESSION_SESSIONS,2)) - (visitor_count * power((sum(m.BARK_BAR_IMPRESSION_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_BARK_BAR_IMPRESSION_SESSIONS
    , case when visitor_count > 1 then (sum(m.BARK_BAR_CLICK_SESSIONS * m.BARK_BAR_IMPRESSION_SESSIONS) - (visitor_count * (sum(m.BARK_BAR_CLICK_SESSIONS) / visitor_count) * (sum(m.BARK_BAR_IMPRESSION_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_BARK_BAR_CTR
    , stddev(m.BARK_BAR_CLICK_SESSIONS) as STDDEV_BARK_BAR_CLICK_SESSIONS
    , stddev(m.BARK_BAR_IMPRESSION_SESSIONS) as STDDEV_BARK_BAR_IMPRESSION_SESSIONS
    , COALESCE(DIV0NULL(sum(m.HOME_PAGE_CLICKS_SESSIONS),visitor_count), 0) as AVG_HOME_PAGE_CLICKS_SESSIONS
    , sum(m.HOME_PAGE_CLICKS_SESSIONS) as SUM_HOME_PAGE_CLICKS_SESSIONS
    , count(distinct m.HOME_PAGE_CLICKS_SESSIONS) as COUNT_DISTINCT_HOME_PAGE_CLICKS_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.HOME_PAGE_CLICKS_SESSIONS,2)) - (visitor_count * power((sum(m.HOME_PAGE_CLICKS_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_HOME_PAGE_CLICKS_SESSIONS
    , case when visitor_count > 1 then (sum(m.BARK_BAR_CLICK_SESSIONS * m.HOME_PAGE_CLICKS_SESSIONS) - (visitor_count * (sum(m.BARK_BAR_CLICK_SESSIONS) / visitor_count) * (sum(m.HOME_PAGE_CLICKS_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_BARK_BAR_CLICKSHARE
    , stddev(m.HOME_PAGE_CLICKS_SESSIONS) as STDDEV_HOME_PAGE_CLICKS_SESSIONS
    , COALESCE(DIV0NULL(sum(m.ORDER_CCP),visitor_count), 0) as AVG_ORDER_CCP
    , sum(m.ORDER_CCP) as SUM_ORDER_CCP
    , count(distinct m.ORDER_CCP) as COUNT_DISTINCT_ORDER_CCP
    , case when visitor_count > 1 then (sum(power(m.ORDER_CCP,2)) - (visitor_count * power((sum(m.ORDER_CCP) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ORDER_CCP
    , NULL as COV_ORDER_CCP
    , stddev(m.ORDER_CCP) as STDDEV_ORDER_CCP
    , case when visitor_count > 1 then (sum(m.PLACED_ORDERS * m.PURCHASE_FLAG) - (visitor_count * (sum(m.PLACED_ORDERS) / visitor_count) * (sum(m.PURCHASE_FLAG) / visitor_count))) / (visitor_count - 1) else 0 end as COV_ORDER_PER_PURCHASER
    , NULL as COV_NET_SALES_PER_VISITOR
    , case when visitor_count > 1 then (sum(m.NET_SALES * m.SESSIONS) - (visitor_count * (sum(m.NET_SALES) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_NET_SALES_PER_SESSION
    , COALESCE(DIV0NULL(sum(m.CHECKOUT_CANCELLED_ORDERS),visitor_count), 0) as AVG_CHECKOUT_CANCELLED_ORDERS
    , sum(m.CHECKOUT_CANCELLED_ORDERS) as SUM_CHECKOUT_CANCELLED_ORDERS
    , count(distinct m.CHECKOUT_CANCELLED_ORDERS) as COUNT_DISTINCT_CHECKOUT_CANCELLED_ORDERS
    , case when visitor_count > 1 then (sum(power(m.CHECKOUT_CANCELLED_ORDERS,2)) - (visitor_count * power((sum(m.CHECKOUT_CANCELLED_ORDERS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_CHECKOUT_CANCELLED_ORDERS
    , case when visitor_count > 1 then (sum(m.CHECKOUT_CANCELLED_ORDERS * m.PLACED_ORDERS) - (visitor_count * (sum(m.CHECKOUT_CANCELLED_ORDERS) / visitor_count) * (sum(m.PLACED_ORDERS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_ORDER_CANCELLATION_RATE
    , stddev(m.CHECKOUT_CANCELLED_ORDERS) as STDDEV_CHECKOUT_CANCELLED_ORDERS
    , COALESCE(DIV0NULL(sum(m.ORDER_NOW_EDIT_PAYMENT_SESSIONS),visitor_count), 0) as AVG_ORDER_NOW_EDIT_PAYMENT_SESSIONS
    , sum(m.ORDER_NOW_EDIT_PAYMENT_SESSIONS) as SUM_ORDER_NOW_EDIT_PAYMENT_SESSIONS
    , count(distinct m.ORDER_NOW_EDIT_PAYMENT_SESSIONS) as COUNT_DISTINCT_ORDER_NOW_EDIT_PAYMENT_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.ORDER_NOW_EDIT_PAYMENT_SESSIONS,2)) - (visitor_count * power((sum(m.ORDER_NOW_EDIT_PAYMENT_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ORDER_NOW_EDIT_PAYMENT_SESSIONS
    , case when visitor_count > 1 then (sum(m.ORDER_NOW_EDIT_PAYMENT_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.ORDER_NOW_EDIT_PAYMENT_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_MAS_ORDER_NOW_EDIT_PAYMENT_RATE
    , stddev(m.ORDER_NOW_EDIT_PAYMENT_SESSIONS) as STDDEV_ORDER_NOW_EDIT_PAYMENT_SESSIONS
    , COALESCE(DIV0NULL(sum(m.ORDER_NOW_EDIT_ADDRESS_SESSIONS),visitor_count), 0) as AVG_ORDER_NOW_EDIT_ADDRESS_SESSIONS
    , sum(m.ORDER_NOW_EDIT_ADDRESS_SESSIONS) as SUM_ORDER_NOW_EDIT_ADDRESS_SESSIONS
    , count(distinct m.ORDER_NOW_EDIT_ADDRESS_SESSIONS) as COUNT_DISTINCT_ORDER_NOW_EDIT_ADDRESS_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.ORDER_NOW_EDIT_ADDRESS_SESSIONS,2)) - (visitor_count * power((sum(m.ORDER_NOW_EDIT_ADDRESS_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_ORDER_NOW_EDIT_ADDRESS_SESSIONS
    , case when visitor_count > 1 then (sum(m.ORDER_NOW_EDIT_ADDRESS_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.ORDER_NOW_EDIT_ADDRESS_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_MAS_ORDER_NOW_EDIT_ADDRESS_RATE
    , stddev(m.ORDER_NOW_EDIT_ADDRESS_SESSIONS) as STDDEV_ORDER_NOW_EDIT_ADDRESS_SESSIONS
    , COALESCE(DIV0NULL(sum(m.HOME_BOUNCE_SESSIONS),visitor_count), 0) as AVG_HOME_BOUNCE_SESSIONS
    , COALESCE(DIV0NULL(sum(m.HOMEPAGE_SESSIONS),visitor_count), 0) as AVG_HOMEPAGE_SESSIONS
    , sum(m.HOME_BOUNCE_SESSIONS) as SUM_HOME_BOUNCE_SESSIONS
    , sum(m.HOMEPAGE_SESSIONS) as SUM_HOMEPAGE_SESSIONS
    , count(distinct m.HOME_BOUNCE_SESSIONS) as COUNT_DISTINCT_HOME_BOUNCE_SESSIONS
    , count(distinct m.HOMEPAGE_SESSIONS) as COUNT_DISTINCT_HOMEPAGE_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.HOME_BOUNCE_SESSIONS,2)) - (visitor_count * power((sum(m.HOME_BOUNCE_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_HOME_BOUNCE_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.HOMEPAGE_SESSIONS,2)) - (visitor_count * power((sum(m.HOMEPAGE_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_HOMEPAGE_SESSIONS
    , case when visitor_count > 1 then (sum(m.HOME_BOUNCE_SESSIONS * m.HOMEPAGE_SESSIONS) - (visitor_count * (sum(m.HOME_BOUNCE_SESSIONS) / visitor_count) * (sum(m.HOMEPAGE_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_HOMEPAGE_BOUNCE_RATE
    , stddev(m.HOME_BOUNCE_SESSIONS) as STDDEV_HOME_BOUNCE_SESSIONS
    , stddev(m.HOMEPAGE_SESSIONS) as STDDEV_HOMEPAGE_SESSIONS
    , COALESCE(DIV0NULL(sum(m.HOME_EXIT_SESSIONS),visitor_count), 0) as AVG_HOME_EXIT_SESSIONS
    , sum(m.HOME_EXIT_SESSIONS) as SUM_HOME_EXIT_SESSIONS
    , count(distinct m.HOME_EXIT_SESSIONS) as COUNT_DISTINCT_HOME_EXIT_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.HOME_EXIT_SESSIONS,2)) - (visitor_count * power((sum(m.HOME_EXIT_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_HOME_EXIT_SESSIONS
    , case when visitor_count > 1 then (sum(m.HOME_EXIT_SESSIONS * m.HOMEPAGE_SESSIONS) - (visitor_count * (sum(m.HOME_EXIT_SESSIONS) / visitor_count) * (sum(m.HOMEPAGE_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_HOMEPAGE_EXIT_RATE
    , stddev(m.HOME_EXIT_SESSIONS) as STDDEV_HOME_EXIT_SESSIONS
    , case when visitor_count > 1 then (sum(m.HOMEPAGE_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.HOMEPAGE_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_HOMEPAGE_SESSIONS_RATE
    , case when visitor_count > 1 then (sum(m.CART_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.CART_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_CART_VISIT_RATE
    , COALESCE(DIV0NULL(sum(m.HOMEPAGE_DISTINCT_WIDGETS),visitor_count), 0) as AVG_HOMEPAGE_DISTINCT_WIDGETS
    , sum(m.HOMEPAGE_DISTINCT_WIDGETS) as SUM_HOMEPAGE_DISTINCT_WIDGETS
    , count(distinct m.HOMEPAGE_DISTINCT_WIDGETS) as COUNT_DISTINCT_HOMEPAGE_DISTINCT_WIDGETS
    , case when visitor_count > 1 then (sum(power(m.HOMEPAGE_DISTINCT_WIDGETS,2)) - (visitor_count * power((sum(m.HOMEPAGE_DISTINCT_WIDGETS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_HOMEPAGE_DISTINCT_WIDGETS
    , NULL as COV_DISTINCT_HOMEPAGE_WIDGETS
    , stddev(m.HOMEPAGE_DISTINCT_WIDGETS) as STDDEV_HOMEPAGE_DISTINCT_WIDGETS
    , COALESCE(DIV0NULL(sum(m.HOMEPAGE_BRAND_PM_IMPRESSIONS),visitor_count), 0) as AVG_HOMEPAGE_BRAND_PM_IMPRESSIONS
    , sum(m.HOMEPAGE_BRAND_PM_IMPRESSIONS) as SUM_HOMEPAGE_BRAND_PM_IMPRESSIONS
    , count(distinct m.HOMEPAGE_BRAND_PM_IMPRESSIONS) as COUNT_DISTINCT_HOMEPAGE_BRAND_PM_IMPRESSIONS
    , case when visitor_count > 1 then (sum(power(m.HOMEPAGE_BRAND_PM_IMPRESSIONS,2)) - (visitor_count * power((sum(m.HOMEPAGE_BRAND_PM_IMPRESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_HOMEPAGE_BRAND_PM_IMPRESSIONS
    , NULL as COV_HOMEPAGE_BRAND_PM_IMPRESSIONS
    , stddev(m.HOMEPAGE_BRAND_PM_IMPRESSIONS) as STDDEV_HOMEPAGE_BRAND_PM_IMPRESSIONS
    , case when visitor_count > 1 then (sum(m.UNCANCELLED_ORDERS_PLACED * m.HOME_PAGE_CLICKS_SESSIONS) - (visitor_count * (sum(m.UNCANCELLED_ORDERS_PLACED) / visitor_count) * (sum(m.HOME_PAGE_CLICKS_SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_HOMEPAGE_CVR
    , COALESCE(DIV0NULL(sum(m.UNCANCELLED_FIRST_APP_ORDERS_PLACED),visitor_count), 0) as AVG_UNCANCELLED_FIRST_APP_ORDERS_PLACED
    , COALESCE(DIV0NULL(sum(m.NEW_TO_APP_ORDER_FLAG),visitor_count), 0) as AVG_NEW_TO_APP_ORDER_FLAG
    , sum(m.UNCANCELLED_FIRST_APP_ORDERS_PLACED) as SUM_UNCANCELLED_FIRST_APP_ORDERS_PLACED
    , sum(m.NEW_TO_APP_ORDER_FLAG) as SUM_NEW_TO_APP_ORDER_FLAG
    , count(distinct m.UNCANCELLED_FIRST_APP_ORDERS_PLACED) as COUNT_DISTINCT_UNCANCELLED_FIRST_APP_ORDERS_PLACED
    , count(distinct m.NEW_TO_APP_ORDER_FLAG) as COUNT_DISTINCT_NEW_TO_APP_ORDER_FLAG
    , case when visitor_count > 1 then (sum(power(m.UNCANCELLED_FIRST_APP_ORDERS_PLACED,2)) - (visitor_count * power((sum(m.UNCANCELLED_FIRST_APP_ORDERS_PLACED) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_UNCANCELLED_FIRST_APP_ORDERS_PLACED
    , case when visitor_count > 1 then (sum(power(m.NEW_TO_APP_ORDER_FLAG,2)) - (visitor_count * power((sum(m.NEW_TO_APP_ORDER_FLAG) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_NEW_TO_APP_ORDER_FLAG
    , case when visitor_count > 1 then (sum(m.UNCANCELLED_FIRST_APP_ORDERS_PLACED * m.NEW_TO_APP_ORDER_FLAG) - (visitor_count * (sum(m.UNCANCELLED_FIRST_APP_ORDERS_PLACED) / visitor_count) * (sum(m.NEW_TO_APP_ORDER_FLAG) / visitor_count))) / (visitor_count - 1) else 0 end as COV_APP_FIRST_ORDER_VISITOR_CVR
    , stddev(m.UNCANCELLED_FIRST_APP_ORDERS_PLACED) as STDDEV_UNCANCELLED_FIRST_APP_ORDERS_PLACED
    , stddev(m.NEW_TO_APP_ORDER_FLAG) as STDDEV_NEW_TO_APP_ORDER_FLAG
    , COALESCE(DIV0NULL(sum(m.PET_PORTAL_SESSIONS),visitor_count), 0) as AVG_PET_PORTAL_SESSIONS
    , sum(m.PET_PORTAL_SESSIONS) as SUM_PET_PORTAL_SESSIONS
    , count(distinct m.PET_PORTAL_SESSIONS) as COUNT_DISTINCT_PET_PORTAL_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.PET_PORTAL_SESSIONS,2)) - (visitor_count * power((sum(m.PET_PORTAL_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_PET_PORTAL_SESSIONS
    , case when visitor_count > 1 then (sum(m.PET_PORTAL_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.PET_PORTAL_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_PET_PORTAL_VISIT_RATE
    , stddev(m.PET_PORTAL_SESSIONS) as STDDEV_PET_PORTAL_SESSIONS
    , COALESCE(DIV0NULL(sum(m.CAREPLUS_SESSIONS),visitor_count), 0) as AVG_CAREPLUS_SESSIONS
    , sum(m.CAREPLUS_SESSIONS) as SUM_CAREPLUS_SESSIONS
    , count(distinct m.CAREPLUS_SESSIONS) as COUNT_DISTINCT_CAREPLUS_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.CAREPLUS_SESSIONS,2)) - (visitor_count * power((sum(m.CAREPLUS_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_CAREPLUS_SESSIONS
    , case when visitor_count > 1 then (sum(m.CAREPLUS_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.CAREPLUS_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_CAREPLUS_VISIT_RATE
    , stddev(m.CAREPLUS_SESSIONS) as STDDEV_CAREPLUS_SESSIONS
    , COALESCE(DIV0NULL(sum(m.CWAV_SESSIONS),visitor_count), 0) as AVG_CWAV_SESSIONS
    , sum(m.CWAV_SESSIONS) as SUM_CWAV_SESSIONS
    , count(distinct m.CWAV_SESSIONS) as COUNT_DISTINCT_CWAV_SESSIONS
    , case when visitor_count > 1 then (sum(power(m.CWAV_SESSIONS,2)) - (visitor_count * power((sum(m.CWAV_SESSIONS) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_CWAV_SESSIONS
    , case when visitor_count > 1 then (sum(m.CWAV_SESSIONS * m.SESSIONS) - (visitor_count * (sum(m.CWAV_SESSIONS) / visitor_count) * (sum(m.SESSIONS) / visitor_count))) / (visitor_count - 1) else 0 end as COV_CWAV_VISIT_RATE
    , stddev(m.CWAV_SESSIONS) as STDDEV_CWAV_SESSIONS
    , COALESCE(DIV0NULL(sum(m.PET_PROFILE_CREATION_COUNT),visitor_count), 0) as AVG_PET_PROFILE_CREATION_COUNT
    , sum(m.PET_PROFILE_CREATION_COUNT) as SUM_PET_PROFILE_CREATION_COUNT
    , count(distinct m.PET_PROFILE_CREATION_COUNT) as COUNT_DISTINCT_PET_PROFILE_CREATION_COUNT
    , case when visitor_count > 1 then (sum(power(m.PET_PROFILE_CREATION_COUNT,2)) - (visitor_count * power((sum(m.PET_PROFILE_CREATION_COUNT) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_PET_PROFILE_CREATION_COUNT
    , NULL as COV_PET_PROFILE_CREATION_RATE
    , stddev(m.PET_PROFILE_CREATION_COUNT) as STDDEV_PET_PROFILE_CREATION_COUNT
    , COALESCE(DIV0NULL(sum(m.PET_PHOTO_UPLOAD_COUNT),visitor_count), 0) as AVG_PET_PHOTO_UPLOAD_COUNT
    , sum(m.PET_PHOTO_UPLOAD_COUNT) as SUM_PET_PHOTO_UPLOAD_COUNT
    , count(distinct m.PET_PHOTO_UPLOAD_COUNT) as COUNT_DISTINCT_PET_PHOTO_UPLOAD_COUNT
    , case when visitor_count > 1 then (sum(power(m.PET_PHOTO_UPLOAD_COUNT,2)) - (visitor_count * power((sum(m.PET_PHOTO_UPLOAD_COUNT) / visitor_count),2))) / (visitor_count - 1) else 0 end  as VARIANCE_PET_PHOTO_UPLOAD_COUNT
    , NULL as COV_PET_PHOTO_UPLOAD_RATE
    , stddev(m.PET_PHOTO_UPLOAD_COUNT) as STDDEV_PET_PHOTO_UPLOAD_COUNT
from TEMP_TEST_METRICS_OUTLIER_FILTERED m
join visitor_counts v on m.data_date = v.data_date AND m.experiment = v.experiment AND m.variation = v.variation
group by $data_date, m.EXPERIMENT, m.VARIATION
;



create or replace  local temp table TEMP_MS_EXP_METRICS_LEVEL_2 as
with
pairwise_json as (
   select a.data_date,
  'ALL' as groupingset_name,
  'session_metrics.sql' as src_file,
  a.EXPERIMENT,
  a.VARIATION,
  COUNT(DISTINCT a.VARIATION) OVER (PARTITION BY a.EXPERIMENT, a.GROUPINGSET_NAME, a.DATA_DATE) AS variation_cnt,
  DIV0NULL(0.05, COUNT(DISTINCT a.VARIATION) OVER (PARTITION BY a.EXPERIMENT, a.GROUPINGSET_NAME, a.DATA_DATE)) AS SIGNIFICANCE,
  ARRAY_CONSTRUCT(
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'PLP_SUCCESS_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_PLP_SUCCESS_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_PLP_SUCCESS_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_PLP_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_PLP_SESSIONS,
      'SUM_NUMERATOR', a.SUM_PLP_SUCCESS_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_PLP_SUCCESS_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_PLP_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_PLP_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_PLP_SUCCESS_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_PLP_SUCCESS_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_PLP_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_PLP_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_PLP_SUCCESS_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_PLP_SUCCESS_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_PLP_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_PLP_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_PLP_SUCCESS_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_PLP_SUCCESS_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_PLP_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_PLP_SESSIONS,
      'COV', a.COV_PLP_SUCCESS_RATE,
      'CONTROL_COV', b.COV_PLP_SUCCESS_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'PDP_SUCCESS_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_PDP_SUCCESS_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_PDP_SUCCESS_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_PDP_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_PDP_SESSIONS,
      'SUM_NUMERATOR', a.SUM_PDP_SUCCESS_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_PDP_SUCCESS_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_PDP_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_PDP_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_PDP_SUCCESS_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_PDP_SUCCESS_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_PDP_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_PDP_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_PDP_SUCCESS_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_PDP_SUCCESS_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_PDP_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_PDP_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_PDP_SUCCESS_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_PDP_SUCCESS_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_PDP_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_PDP_SESSIONS,
      'COV', a.COV_PDP_SUCCESS_RATE,
      'CONTROL_COV', b.COV_PDP_SUCCESS_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'ATC_SUCCESS_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ATC_SUCCESS_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ATC_SUCCESS_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_ATC_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_ATC_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ATC_SUCCESS_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ATC_SUCCESS_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_ATC_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_ATC_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ATC_SUCCESS_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ATC_SUCCESS_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_ATC_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_ATC_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ATC_SUCCESS_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ATC_SUCCESS_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_ATC_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_ATC_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ATC_SUCCESS_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ATC_SUCCESS_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_ATC_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_ATC_SESSIONS,
      'COV', a.COV_ATC_SUCCESS_RATE,
      'CONTROL_COV', b.COV_ATC_SUCCESS_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'CHECKOUT_SUCCESS_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_CHECKOUT_SUCCESS_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_CHECKOUT_SUCCESS_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_CHECKOUT_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_CHECKOUT_SESSIONS,
      'SUM_NUMERATOR', a.SUM_CHECKOUT_SUCCESS_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_CHECKOUT_SUCCESS_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_CHECKOUT_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_CHECKOUT_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_CHECKOUT_SUCCESS_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_CHECKOUT_SUCCESS_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_CHECKOUT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_CHECKOUT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_CHECKOUT_SUCCESS_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_CHECKOUT_SUCCESS_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_CHECKOUT_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_CHECKOUT_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_CHECKOUT_SUCCESS_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_CHECKOUT_SUCCESS_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_CHECKOUT_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_CHECKOUT_SESSIONS,
      'COV', a.COV_CHECKOUT_SUCCESS_RATE,
      'CONTROL_COV', b.COV_CHECKOUT_SUCCESS_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'CART_ABANDONMENT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_CHECKOUT_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_CHECKOUT_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_ATC_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_ATC_SESSIONS,
      'SUM_NUMERATOR', a.SUM_CHECKOUT_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_CHECKOUT_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_ATC_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_ATC_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_CHECKOUT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_CHECKOUT_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_ATC_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_ATC_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_CHECKOUT_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_CHECKOUT_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_ATC_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_ATC_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_CHECKOUT_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_CHECKOUT_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_ATC_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_ATC_SESSIONS,
      'COV', a.COV_CART_ABANDONMENT_RATE,
      'CONTROL_COV', b.COV_CART_ABANDONMENT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'CART_PAGE_SUCCESS_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_CART_SUCCESS_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_CART_SUCCESS_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_CART_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_CART_SESSIONS,
      'SUM_NUMERATOR', a.SUM_CART_SUCCESS_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_CART_SUCCESS_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_CART_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_CART_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_CART_SUCCESS_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_CART_SUCCESS_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_CART_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_CART_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_CART_SUCCESS_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_CART_SUCCESS_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_CART_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_CART_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_CART_SUCCESS_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_CART_SUCCESS_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_CART_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_CART_SESSIONS,
      'COV', a.COV_CART_PAGE_SUCCESS_RATE,
      'CONTROL_COV', b.COV_CART_PAGE_SUCCESS_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'CVR',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_PLACED_ORDERS,
      'CONTROL_AVG_NUMERATOR', b.AVG_PLACED_ORDERS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_PLACED_ORDERS,
      'CONTROL_SUM_NUMERATOR', b.SUM_PLACED_ORDERS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_PLACED_ORDERS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_PLACED_ORDERS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_PLACED_ORDERS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_PLACED_ORDERS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_PLACED_ORDERS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_PLACED_ORDERS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_CVR,
      'CONTROL_COV', b.COV_CVR
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'UNIQUE_CVR',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_PURCHASE_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_PURCHASE_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_PURCHASE_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_PURCHASE_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_PURCHASE_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_PURCHASE_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_PURCHASE_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_PURCHASE_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_PURCHASE_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_PURCHASE_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_UNIQUE_CVR,
      'CONTROL_COV', b.COV_UNIQUE_CVR
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'MERCH_ASP',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_MERCH_SALES,
      'CONTROL_AVG_NUMERATOR', b.AVG_MERCH_SALES,
      'AVG_DENOMINATOR', a.AVG_TRANSACTION_QUANTITY,
      'CONTROL_AVG_DENOMINATOR', b.AVG_TRANSACTION_QUANTITY,
      'SUM_NUMERATOR', a.SUM_MERCH_SALES,
      'CONTROL_SUM_NUMERATOR', b.SUM_MERCH_SALES,
      'SUM_DENOMINATOR', a.SUM_TRANSACTION_QUANTITY,
      'CONTROL_SUM_DENOMINATOR', b.SUM_TRANSACTION_QUANTITY,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_MERCH_SALES,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_MERCH_SALES,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_TRANSACTION_QUANTITY,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_TRANSACTION_QUANTITY,
      'VARIANCE_NUMERATOR', a.VARIANCE_MERCH_SALES,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_MERCH_SALES,
      'VARIANCE_DENOMINATOR', a.VARIANCE_TRANSACTION_QUANTITY,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_TRANSACTION_QUANTITY,
      'STDDEV_NUMERATOR', a.STDDEV_MERCH_SALES,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_MERCH_SALES,
      'STDDEV_DENOMINATOR', a.STDDEV_TRANSACTION_QUANTITY,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_TRANSACTION_QUANTITY,
      'COV', a.COV_MERCH_ASP,
      'CONTROL_COV', b.COV_MERCH_ASP
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'AOV_MERCH_SALES',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_MERCH_SALES,
      'CONTROL_AVG_NUMERATOR', b.AVG_MERCH_SALES,
      'AVG_DENOMINATOR', a.AVG_NOT_CANCELLED_ORDERS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_NOT_CANCELLED_ORDERS,
      'SUM_NUMERATOR', a.SUM_MERCH_SALES,
      'CONTROL_SUM_NUMERATOR', b.SUM_MERCH_SALES,
      'SUM_DENOMINATOR', a.SUM_NOT_CANCELLED_ORDERS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_NOT_CANCELLED_ORDERS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_MERCH_SALES,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_MERCH_SALES,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_NOT_CANCELLED_ORDERS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_NOT_CANCELLED_ORDERS,
      'VARIANCE_NUMERATOR', a.VARIANCE_MERCH_SALES,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_MERCH_SALES,
      'VARIANCE_DENOMINATOR', a.VARIANCE_NOT_CANCELLED_ORDERS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_NOT_CANCELLED_ORDERS,
      'STDDEV_NUMERATOR', a.STDDEV_MERCH_SALES,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_MERCH_SALES,
      'STDDEV_DENOMINATOR', a.STDDEV_NOT_CANCELLED_ORDERS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_NOT_CANCELLED_ORDERS,
      'COV', a.COV_AOV_MERCH_SALES,
      'CONTROL_COV', b.COV_AOV_MERCH_SALES
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'NET_UPO',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_TRANSACTION_QUANTITY,
      'CONTROL_AVG_NUMERATOR', b.AVG_TRANSACTION_QUANTITY,
      'AVG_DENOMINATOR', a.AVG_NOT_CANCELLED_ORDERS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_NOT_CANCELLED_ORDERS,
      'SUM_NUMERATOR', a.SUM_TRANSACTION_QUANTITY,
      'CONTROL_SUM_NUMERATOR', b.SUM_TRANSACTION_QUANTITY,
      'SUM_DENOMINATOR', a.SUM_NOT_CANCELLED_ORDERS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_NOT_CANCELLED_ORDERS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_TRANSACTION_QUANTITY,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_TRANSACTION_QUANTITY,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_NOT_CANCELLED_ORDERS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_NOT_CANCELLED_ORDERS,
      'VARIANCE_NUMERATOR', a.VARIANCE_TRANSACTION_QUANTITY,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_TRANSACTION_QUANTITY,
      'VARIANCE_DENOMINATOR', a.VARIANCE_NOT_CANCELLED_ORDERS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_NOT_CANCELLED_ORDERS,
      'STDDEV_NUMERATOR', a.STDDEV_TRANSACTION_QUANTITY,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_TRANSACTION_QUANTITY,
      'STDDEV_DENOMINATOR', a.STDDEV_NOT_CANCELLED_ORDERS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_NOT_CANCELLED_ORDERS,
      'COV', a.COV_NET_UPO,
      'CONTROL_COV', b.COV_NET_UPO
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'OVERALL_ATC_ATA_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ATC_ATA_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ATC_ATA_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ATC_ATA_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ATC_ATA_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ATC_ATA_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ATC_ATA_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ATC_ATA_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ATC_ATA_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ATC_ATA_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ATC_ATA_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_OVERALL_ATC_ATA_RATE,
      'CONTROL_COV', b.COV_OVERALL_ATC_ATA_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'OVERALL_ATC_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ATC_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ATC_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ATC_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ATC_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ATC_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ATC_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ATC_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ATC_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ATC_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ATC_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_OVERALL_ATC_RATE,
      'CONTROL_COV', b.COV_OVERALL_ATC_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'OVERALL_ATA_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ATA_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ATA_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ATA_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ATA_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ATA_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ATA_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ATA_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ATA_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ATA_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ATA_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_OVERALL_ATA_RATE,
      'CONTROL_COV', b.COV_OVERALL_ATA_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'PDP_ATC_ATA_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ATC_ATA_PDP_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ATC_ATA_PDP_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_PDP_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_PDP_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ATC_ATA_PDP_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ATC_ATA_PDP_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_PDP_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_PDP_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ATC_ATA_PDP_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ATC_ATA_PDP_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_PDP_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_PDP_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ATC_ATA_PDP_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ATC_ATA_PDP_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_PDP_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_PDP_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ATC_ATA_PDP_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ATC_ATA_PDP_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_PDP_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_PDP_SESSIONS,
      'COV', a.COV_PDP_ATC_ATA_RATE,
      'CONTROL_COV', b.COV_PDP_ATC_ATA_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'PDP_ATC_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ATC_PDP_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ATC_PDP_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_PDP_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_PDP_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ATC_PDP_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ATC_PDP_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_PDP_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_PDP_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ATC_PDP_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ATC_PDP_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_PDP_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_PDP_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ATC_PDP_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ATC_PDP_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_PDP_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_PDP_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ATC_PDP_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ATC_PDP_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_PDP_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_PDP_SESSIONS,
      'COV', a.COV_PDP_ATC_RATE,
      'CONTROL_COV', b.COV_PDP_ATC_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'PDP_ATA_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ATA_PDP_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ATA_PDP_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_PDP_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_PDP_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ATA_PDP_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ATA_PDP_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_PDP_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_PDP_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ATA_PDP_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ATA_PDP_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_PDP_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_PDP_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ATA_PDP_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ATA_PDP_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_PDP_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_PDP_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ATA_PDP_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ATA_PDP_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_PDP_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_PDP_SESSIONS,
      'COV', a.COV_PDP_ATA_RATE,
      'CONTROL_COV', b.COV_PDP_ATA_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'PDP_BUYBOX_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_PDP_BUYBOX_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_PDP_BUYBOX_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_PDP_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_PDP_SESSIONS,
      'SUM_NUMERATOR', a.SUM_PDP_BUYBOX_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_PDP_BUYBOX_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_PDP_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_PDP_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_PDP_BUYBOX_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_PDP_BUYBOX_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_PDP_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_PDP_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_PDP_BUYBOX_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_PDP_BUYBOX_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_PDP_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_PDP_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_PDP_BUYBOX_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_PDP_BUYBOX_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_PDP_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_PDP_SESSIONS,
      'COV', a.COV_PDP_BUYBOX_RATE,
      'CONTROL_COV', b.COV_PDP_BUYBOX_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'PDP_CAROUSEL_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_PDP_CAROUSEL_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_PDP_CAROUSEL_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_PDP_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_PDP_SESSIONS,
      'SUM_NUMERATOR', a.SUM_PDP_CAROUSEL_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_PDP_CAROUSEL_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_PDP_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_PDP_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_PDP_CAROUSEL_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_PDP_CAROUSEL_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_PDP_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_PDP_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_PDP_CAROUSEL_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_PDP_CAROUSEL_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_PDP_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_PDP_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_PDP_CAROUSEL_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_PDP_CAROUSEL_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_PDP_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_PDP_SESSIONS,
      'COV', a.COV_PDP_CAROUSEL_RATE,
      'CONTROL_COV', b.COV_PDP_CAROUSEL_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'ADS_REVENUE_PER_SESSION',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ADS_REVENUE,
      'CONTROL_AVG_NUMERATOR', b.AVG_ADS_REVENUE,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ADS_REVENUE,
      'CONTROL_SUM_NUMERATOR', b.SUM_ADS_REVENUE,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ADS_REVENUE,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ADS_REVENUE,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ADS_REVENUE,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ADS_REVENUE,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ADS_REVENUE,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ADS_REVENUE,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_ADS_REVENUE_PER_SESSION,
      'CONTROL_COV', b.COV_ADS_REVENUE_PER_SESSION
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'ADS_REVENUE_PER_VISITOR',
      'metric_type', 'mean',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ADS_REVENUE,
      'CONTROL_AVG_NUMERATOR', b.AVG_ADS_REVENUE,
      'SUM_NUMERATOR', a.SUM_ADS_REVENUE,
      'CONTROL_SUM_NUMERATOR', b.SUM_ADS_REVENUE,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ADS_REVENUE,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ADS_REVENUE,
      'VARIANCE_NUMERATOR', a.VARIANCE_ADS_REVENUE,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ADS_REVENUE,
      'STDDEV_NUMERATOR', a.STDDEV_ADS_REVENUE,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ADS_REVENUE,
      'COV', a.COV_ADS_REVENUE_PER_VISITOR,
      'CONTROL_COV', b.COV_ADS_REVENUE_PER_VISITOR
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'UNIQUE_VISITOR_CVR',
      'metric_type', 'rate',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_PURCHASE_FLAG,
      'CONTROL_AVG_NUMERATOR', b.AVG_PURCHASE_FLAG,
      'SUM_NUMERATOR', a.SUM_PURCHASE_FLAG,
      'CONTROL_SUM_NUMERATOR', b.SUM_PURCHASE_FLAG,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_PURCHASE_FLAG,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_PURCHASE_FLAG,
      'VARIANCE_NUMERATOR', a.VARIANCE_PURCHASE_FLAG,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_PURCHASE_FLAG,
      'STDDEV_NUMERATOR', a.STDDEV_PURCHASE_FLAG,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_PURCHASE_FLAG,
      'COV', a.COV_UNIQUE_VISITOR_CVR,
      'CONTROL_COV', b.COV_UNIQUE_VISITOR_CVR
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'CVR_ATA_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_TOTAL_PROJECTED_ORDERS_90_DAYS,
      'CONTROL_AVG_NUMERATOR', b.AVG_TOTAL_PROJECTED_ORDERS_90_DAYS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_TOTAL_PROJECTED_ORDERS_90_DAYS,
      'CONTROL_SUM_NUMERATOR', b.SUM_TOTAL_PROJECTED_ORDERS_90_DAYS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_TOTAL_PROJECTED_ORDERS_90_DAYS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_TOTAL_PROJECTED_ORDERS_90_DAYS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_TOTAL_PROJECTED_ORDERS_90_DAYS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_TOTAL_PROJECTED_ORDERS_90_DAYS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_TOTAL_PROJECTED_ORDERS_90_DAYS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_TOTAL_PROJECTED_ORDERS_90_DAYS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_CVR_ATA_RATE,
      'CONTROL_COV', b.COV_CVR_ATA_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'CCV',
      'metric_type', 'mean',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_CCV,
      'CONTROL_AVG_NUMERATOR', b.AVG_CCV,
      'SUM_NUMERATOR', a.SUM_CCV,
      'CONTROL_SUM_NUMERATOR', b.SUM_CCV,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_CCV,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_CCV,
      'VARIANCE_NUMERATOR', a.VARIANCE_CCV,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_CCV,
      'STDDEV_NUMERATOR', a.STDDEV_CCV,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_CCV,
      'COV', a.COV_CCV,
      'CONTROL_COV', b.COV_CCV
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'CCV_PER_SESSION',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_CCV,
      'CONTROL_AVG_NUMERATOR', b.AVG_CCV,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_CCV,
      'CONTROL_SUM_NUMERATOR', b.SUM_CCV,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_CCV,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_CCV,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_CCV,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_CCV,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_CCV,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_CCV,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_CCV_PER_SESSION,
      'CONTROL_COV', b.COV_CCV_PER_SESSION
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'MERCH_SALES_PER_SESSION',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_MERCH_SALES,
      'CONTROL_AVG_NUMERATOR', b.AVG_MERCH_SALES,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_MERCH_SALES,
      'CONTROL_SUM_NUMERATOR', b.SUM_MERCH_SALES,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_MERCH_SALES,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_MERCH_SALES,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_MERCH_SALES,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_MERCH_SALES,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_MERCH_SALES,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_MERCH_SALES,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_MERCH_SALES_PER_SESSION,
      'CONTROL_COV', b.COV_MERCH_SALES_PER_SESSION
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'GROSS_MARGIN_PER_SESSION',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_GROSS_MARGIN,
      'CONTROL_AVG_NUMERATOR', b.AVG_GROSS_MARGIN,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_GROSS_MARGIN,
      'CONTROL_SUM_NUMERATOR', b.SUM_GROSS_MARGIN,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_GROSS_MARGIN,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_GROSS_MARGIN,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_GROSS_MARGIN,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_GROSS_MARGIN,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_GROSS_MARGIN,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_GROSS_MARGIN,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_GROSS_MARGIN_PER_SESSION,
      'CONTROL_COV', b.COV_GROSS_MARGIN_PER_SESSION
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'MERCH_SALES_PER_VISITOR',
      'metric_type', 'mean',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_MERCH_SALES,
      'CONTROL_AVG_NUMERATOR', b.AVG_MERCH_SALES,
      'SUM_NUMERATOR', a.SUM_MERCH_SALES,
      'CONTROL_SUM_NUMERATOR', b.SUM_MERCH_SALES,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_MERCH_SALES,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_MERCH_SALES,
      'VARIANCE_NUMERATOR', a.VARIANCE_MERCH_SALES,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_MERCH_SALES,
      'STDDEV_NUMERATOR', a.STDDEV_MERCH_SALES,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_MERCH_SALES,
      'COV', a.COV_MERCH_SALES_PER_VISITOR,
      'CONTROL_COV', b.COV_MERCH_SALES_PER_VISITOR
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'ORDER_PER_VISITOR',
      'metric_type', 'mean',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_PLACED_ORDERS,
      'CONTROL_AVG_NUMERATOR', b.AVG_PLACED_ORDERS,
      'SUM_NUMERATOR', a.SUM_PLACED_ORDERS,
      'CONTROL_SUM_NUMERATOR', b.SUM_PLACED_ORDERS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_PLACED_ORDERS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_PLACED_ORDERS,
      'VARIANCE_NUMERATOR', a.VARIANCE_PLACED_ORDERS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_PLACED_ORDERS,
      'STDDEV_NUMERATOR', a.STDDEV_PLACED_ORDERS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_PLACED_ORDERS,
      'COV', a.COV_ORDER_PER_VISITOR,
      'CONTROL_COV', b.COV_ORDER_PER_VISITOR
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'AUTOSHIP_CHECKOUT_SUCCESS_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS,
      'SUM_NUMERATOR', a.SUM_AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_AUTOSHIP_ELIGIBLE_CHECKOUT_SUCCESS_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_AUTOSHIP_ELIGIBLE_CHECKOUT_SESSIONS,
      'COV', a.COV_AUTOSHIP_CHECKOUT_SUCCESS_RATE,
      'CONTROL_COV', b.COV_AUTOSHIP_CHECKOUT_SUCCESS_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'AD_CTR',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ADS_CLICKS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ADS_CLICKS,
      'AVG_DENOMINATOR', a.AVG_ADS_IMPRESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_ADS_IMPRESSIONS,
      'SUM_NUMERATOR', a.SUM_ADS_CLICKS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ADS_CLICKS,
      'SUM_DENOMINATOR', a.SUM_ADS_IMPRESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_ADS_IMPRESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ADS_CLICKS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ADS_CLICKS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_ADS_IMPRESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_ADS_IMPRESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ADS_CLICKS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ADS_CLICKS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_ADS_IMPRESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_ADS_IMPRESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ADS_CLICKS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ADS_CLICKS,
      'STDDEV_DENOMINATOR', a.STDDEV_ADS_IMPRESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_ADS_IMPRESSIONS,
      'COV', a.COV_AD_CTR,
      'CONTROL_COV', b.COV_AD_CTR
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'AD_ROAS_24H',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ADS_DIRECT_SALES_24H,
      'CONTROL_AVG_NUMERATOR', b.AVG_ADS_DIRECT_SALES_24H,
      'AVG_DENOMINATOR', a.AVG_ADS_REVENUE,
      'CONTROL_AVG_DENOMINATOR', b.AVG_ADS_REVENUE,
      'SUM_NUMERATOR', a.SUM_ADS_DIRECT_SALES_24H,
      'CONTROL_SUM_NUMERATOR', b.SUM_ADS_DIRECT_SALES_24H,
      'SUM_DENOMINATOR', a.SUM_ADS_REVENUE,
      'CONTROL_SUM_DENOMINATOR', b.SUM_ADS_REVENUE,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ADS_DIRECT_SALES_24H,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ADS_DIRECT_SALES_24H,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_ADS_REVENUE,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_ADS_REVENUE,
      'VARIANCE_NUMERATOR', a.VARIANCE_ADS_DIRECT_SALES_24H,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ADS_DIRECT_SALES_24H,
      'VARIANCE_DENOMINATOR', a.VARIANCE_ADS_REVENUE,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_ADS_REVENUE,
      'STDDEV_NUMERATOR', a.STDDEV_ADS_DIRECT_SALES_24H,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ADS_DIRECT_SALES_24H,
      'STDDEV_DENOMINATOR', a.STDDEV_ADS_REVENUE,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_ADS_REVENUE,
      'COV', a.COV_AD_ROAS_24H,
      'CONTROL_COV', b.COV_AD_ROAS_24H
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'AD_CVR_24H',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ADS_QUANTITY_24H,
      'CONTROL_AVG_NUMERATOR', b.AVG_ADS_QUANTITY_24H,
      'AVG_DENOMINATOR', a.AVG_ADS_CLICKS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_ADS_CLICKS,
      'SUM_NUMERATOR', a.SUM_ADS_QUANTITY_24H,
      'CONTROL_SUM_NUMERATOR', b.SUM_ADS_QUANTITY_24H,
      'SUM_DENOMINATOR', a.SUM_ADS_CLICKS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_ADS_CLICKS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ADS_QUANTITY_24H,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ADS_QUANTITY_24H,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_ADS_CLICKS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_ADS_CLICKS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ADS_QUANTITY_24H,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ADS_QUANTITY_24H,
      'VARIANCE_DENOMINATOR', a.VARIANCE_ADS_CLICKS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_ADS_CLICKS,
      'STDDEV_NUMERATOR', a.STDDEV_ADS_QUANTITY_24H,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ADS_QUANTITY_24H,
      'STDDEV_DENOMINATOR', a.STDDEV_ADS_CLICKS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_ADS_CLICKS,
      'COV', a.COV_AD_CVR_24H,
      'CONTROL_COV', b.COV_AD_CVR_24H
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'AD_ECPM',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ADS_REVENUE,
      'CONTROL_AVG_NUMERATOR', b.AVG_ADS_REVENUE,
      'AVG_DENOMINATOR', a.AVG_ADS_IMPRESSIONS_PER_1000,
      'CONTROL_AVG_DENOMINATOR', b.AVG_ADS_IMPRESSIONS_PER_1000,
      'SUM_NUMERATOR', a.SUM_ADS_REVENUE,
      'CONTROL_SUM_NUMERATOR', b.SUM_ADS_REVENUE,
      'SUM_DENOMINATOR', a.SUM_ADS_IMPRESSIONS_PER_1000,
      'CONTROL_SUM_DENOMINATOR', b.SUM_ADS_IMPRESSIONS_PER_1000,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ADS_REVENUE,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ADS_REVENUE,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_ADS_IMPRESSIONS_PER_1000,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_ADS_IMPRESSIONS_PER_1000,
      'VARIANCE_NUMERATOR', a.VARIANCE_ADS_REVENUE,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ADS_REVENUE,
      'VARIANCE_DENOMINATOR', a.VARIANCE_ADS_IMPRESSIONS_PER_1000,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_ADS_IMPRESSIONS_PER_1000,
      'STDDEV_NUMERATOR', a.STDDEV_ADS_REVENUE,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ADS_REVENUE,
      'STDDEV_DENOMINATOR', a.STDDEV_ADS_IMPRESSIONS_PER_1000,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_ADS_IMPRESSIONS_PER_1000,
      'COV', a.COV_AD_ECPM,
      'CONTROL_COV', b.COV_AD_ECPM
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'AD_CPC',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ADS_REVENUE,
      'CONTROL_AVG_NUMERATOR', b.AVG_ADS_REVENUE,
      'AVG_DENOMINATOR', a.AVG_ADS_CLICKS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_ADS_CLICKS,
      'SUM_NUMERATOR', a.SUM_ADS_REVENUE,
      'CONTROL_SUM_NUMERATOR', b.SUM_ADS_REVENUE,
      'SUM_DENOMINATOR', a.SUM_ADS_CLICKS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_ADS_CLICKS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ADS_REVENUE,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ADS_REVENUE,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_ADS_CLICKS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_ADS_CLICKS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ADS_REVENUE,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ADS_REVENUE,
      'VARIANCE_DENOMINATOR', a.VARIANCE_ADS_CLICKS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_ADS_CLICKS,
      'STDDEV_NUMERATOR', a.STDDEV_ADS_REVENUE,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ADS_REVENUE,
      'STDDEV_DENOMINATOR', a.STDDEV_ADS_CLICKS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_ADS_CLICKS,
      'COV', a.COV_AD_CPC,
      'CONTROL_COV', b.COV_AD_CPC
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'AD_IMPRESSIONS_PER_SESSION',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ADS_IMPRESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ADS_IMPRESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ADS_IMPRESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ADS_IMPRESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ADS_IMPRESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ADS_IMPRESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ADS_IMPRESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ADS_IMPRESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ADS_IMPRESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ADS_IMPRESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_AD_IMPRESSIONS_PER_SESSION,
      'CONTROL_COV', b.COV_AD_IMPRESSIONS_PER_SESSION
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'ADS_IMPRESSIONS_PER_VISITOR',
      'metric_type', 'mean',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ADS_IMPRESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ADS_IMPRESSIONS,
      'SUM_NUMERATOR', a.SUM_ADS_IMPRESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ADS_IMPRESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ADS_IMPRESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ADS_IMPRESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ADS_IMPRESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ADS_IMPRESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ADS_IMPRESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ADS_IMPRESSIONS,
      'COV', a.COV_ADS_IMPRESSIONS_PER_VISITOR,
      'CONTROL_COV', b.COV_ADS_IMPRESSIONS_PER_VISITOR
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'AD_CLICKS_PER_SESSION',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ADS_CLICKS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ADS_CLICKS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ADS_CLICKS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ADS_CLICKS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ADS_CLICKS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ADS_CLICKS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ADS_CLICKS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ADS_CLICKS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ADS_CLICKS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ADS_CLICKS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_AD_CLICKS_PER_SESSION,
      'CONTROL_COV', b.COV_AD_CLICKS_PER_SESSION
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'AD_CLICKS_PER_VISITOR',
      'metric_type', 'mean',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ADS_CLICKS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ADS_CLICKS,
      'SUM_NUMERATOR', a.SUM_ADS_CLICKS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ADS_CLICKS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ADS_CLICKS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ADS_CLICKS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ADS_CLICKS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ADS_CLICKS,
      'STDDEV_NUMERATOR', a.STDDEV_ADS_CLICKS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ADS_CLICKS,
      'COV', a.COV_AD_CLICKS_PER_VISITOR,
      'CONTROL_COV', b.COV_AD_CLICKS_PER_VISITOR
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'SESSIONS_PER_VISITOR',
      'metric_type', 'mean',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_SESSIONS_PER_VISITOR,
      'CONTROL_COV', b.COV_SESSIONS_PER_VISITOR
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'PLP_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_PLP_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_PLP_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_PLP_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_PLP_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_PLP_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_PLP_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_PLP_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_PLP_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_PLP_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_PLP_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_PLP_RATE,
      'CONTROL_COV', b.COV_PLP_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'PDP_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_PDP_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_PDP_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_PDP_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_PDP_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_PDP_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_PDP_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_PDP_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_PDP_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_PDP_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_PDP_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_PDP_RATE,
      'CONTROL_COV', b.COV_PDP_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'ATC_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ATC_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ATC_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ATC_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ATC_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ATC_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ATC_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ATC_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ATC_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ATC_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ATC_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_ATC_RATE,
      'CONTROL_COV', b.COV_ATC_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'CHECKOUT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_CHECKOUT_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_CHECKOUT_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_CHECKOUT_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_CHECKOUT_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_CHECKOUT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_CHECKOUT_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_CHECKOUT_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_CHECKOUT_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_CHECKOUT_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_CHECKOUT_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_CHECKOUT_RATE,
      'CONTROL_COV', b.COV_CHECKOUT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'AUTOSHIP_SUBSCRIPTION_CANCELLATION_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_CANCELLED_SUBSCRIPTION_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_CANCELLED_SUBSCRIPTION_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_CANCELLED_SUBSCRIPTION_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_CANCELLED_SUBSCRIPTION_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_CANCELLED_SUBSCRIPTION_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_CANCELLED_SUBSCRIPTION_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_CANCELLED_SUBSCRIPTION_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_CANCELLED_SUBSCRIPTION_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_CANCELLED_SUBSCRIPTION_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_CANCELLED_SUBSCRIPTION_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_AUTOSHIP_SUBSCRIPTION_CANCELLATION_RATE,
      'CONTROL_COV', b.COV_AUTOSHIP_SUBSCRIPTION_CANCELLATION_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'LIST_AS_PAGE_VISIT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_LIST_AS_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_LIST_AS_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_LIST_AS_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_LIST_AS_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_LIST_AS_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_LIST_AS_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_LIST_AS_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_LIST_AS_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_LIST_AS_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_LIST_AS_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_LIST_AS_PAGE_VISIT_RATE,
      'CONTROL_COV', b.COV_LIST_AS_PAGE_VISIT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'MANAGE_AS_PAGE_VISIT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_MAS_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_MAS_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_MAS_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_MAS_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_MAS_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_MAS_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_MAS_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_MAS_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_MAS_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_MAS_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_MANAGE_AS_PAGE_VISIT_RATE,
      'CONTROL_COV', b.COV_MANAGE_AS_PAGE_VISIT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'TOTAL_MGMT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_MGMT_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_MGMT_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_MGMT_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_MGMT_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_MGMT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_MGMT_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_MGMT_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_MGMT_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_MGMT_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_MGMT_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_TOTAL_MGMT_RATE,
      'CONTROL_COV', b.COV_TOTAL_MGMT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'AS_ORDER_RESCHEDULING_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_AS_ORDER_RESCHEDULE_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_AS_ORDER_RESCHEDULE_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_AS_ORDER_RESCHEDULE_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_AS_ORDER_RESCHEDULE_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_AS_ORDER_RESCHEDULE_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_AS_ORDER_RESCHEDULE_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_AS_ORDER_RESCHEDULE_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_AS_ORDER_RESCHEDULE_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_AS_ORDER_RESCHEDULE_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_AS_ORDER_RESCHEDULE_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_AS_ORDER_RESCHEDULING_RATE,
      'CONTROL_COV', b.COV_AS_ORDER_RESCHEDULING_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'ORDER_NOW_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ORDER_NOW_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ORDER_NOW_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ORDER_NOW_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ORDER_NOW_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ORDER_NOW_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ORDER_NOW_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ORDER_NOW_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ORDER_NOW_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ORDER_NOW_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ORDER_NOW_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_ORDER_NOW_RATE,
      'CONTROL_COV', b.COV_ORDER_NOW_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'SKIP_ORDER_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_SKIP_ORDER_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_SKIP_ORDER_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_SKIP_ORDER_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_SKIP_ORDER_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_SKIP_ORDER_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_SKIP_ORDER_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_SKIP_ORDER_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_SKIP_ORDER_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_SKIP_ORDER_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_SKIP_ORDER_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_SKIP_ORDER_RATE,
      'CONTROL_COV', b.COV_SKIP_ORDER_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'SNOOZE_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_SNOOZE_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_SNOOZE_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_SNOOZE_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_SNOOZE_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_SNOOZE_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_SNOOZE_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_SNOOZE_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_SNOOZE_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_SNOOZE_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_SNOOZE_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_SNOOZE_RATE,
      'CONTROL_COV', b.COV_SNOOZE_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'AS_FREQUENCY_CHANGE_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_CHANGE_FREQUENCY_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_CHANGE_FREQUENCY_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_CHANGE_FREQUENCY_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_CHANGE_FREQUENCY_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_CHANGE_FREQUENCY_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_CHANGE_FREQUENCY_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_CHANGE_FREQUENCY_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_CHANGE_FREQUENCY_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_CHANGE_FREQUENCY_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_CHANGE_FREQUENCY_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_AS_FREQUENCY_CHANGE_RATE,
      'CONTROL_COV', b.COV_AS_FREQUENCY_CHANGE_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'ITEM_MANAGEMENT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ITEM_MGMT_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ITEM_MGMT_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ITEM_MGMT_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ITEM_MGMT_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ITEM_MGMT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ITEM_MGMT_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ITEM_MGMT_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ITEM_MGMT_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ITEM_MGMT_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ITEM_MGMT_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_ITEM_MANAGEMENT_RATE,
      'CONTROL_COV', b.COV_ITEM_MANAGEMENT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'SUBSCRIPTIONS_SETTINGS_MANAGEMENT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_SUB_SETTING_MGMT_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_SUB_SETTING_MGMT_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_SUB_SETTING_MGMT_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_SUB_SETTING_MGMT_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_SUB_SETTING_MGMT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_SUB_SETTING_MGMT_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_SUB_SETTING_MGMT_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_SUB_SETTING_MGMT_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_SUB_SETTING_MGMT_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_SUB_SETTING_MGMT_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_SUBSCRIPTIONS_SETTINGS_MANAGEMENT_RATE,
      'CONTROL_COV', b.COV_SUBSCRIPTIONS_SETTINGS_MANAGEMENT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'NET_AOV',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_NET_SALES,
      'CONTROL_AVG_NUMERATOR', b.AVG_NET_SALES,
      'AVG_DENOMINATOR', a.AVG_UNCANCELLED_ORDERS_PLACED,
      'CONTROL_AVG_DENOMINATOR', b.AVG_UNCANCELLED_ORDERS_PLACED,
      'SUM_NUMERATOR', a.SUM_NET_SALES,
      'CONTROL_SUM_NUMERATOR', b.SUM_NET_SALES,
      'SUM_DENOMINATOR', a.SUM_UNCANCELLED_ORDERS_PLACED,
      'CONTROL_SUM_DENOMINATOR', b.SUM_UNCANCELLED_ORDERS_PLACED,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_NET_SALES,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_NET_SALES,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_UNCANCELLED_ORDERS_PLACED,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_UNCANCELLED_ORDERS_PLACED,
      'VARIANCE_NUMERATOR', a.VARIANCE_NET_SALES,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_NET_SALES,
      'VARIANCE_DENOMINATOR', a.VARIANCE_UNCANCELLED_ORDERS_PLACED,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_UNCANCELLED_ORDERS_PLACED,
      'STDDEV_NUMERATOR', a.STDDEV_NET_SALES,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_NET_SALES,
      'STDDEV_DENOMINATOR', a.STDDEV_UNCANCELLED_ORDERS_PLACED,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_UNCANCELLED_ORDERS_PLACED,
      'COV', a.COV_NET_AOV,
      'CONTROL_COV', b.COV_NET_AOV
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'MERCH_AOV',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_MERCH_SALES,
      'CONTROL_AVG_NUMERATOR', b.AVG_MERCH_SALES,
      'AVG_DENOMINATOR', a.AVG_PLACED_ORDERS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_PLACED_ORDERS,
      'SUM_NUMERATOR', a.SUM_MERCH_SALES,
      'CONTROL_SUM_NUMERATOR', b.SUM_MERCH_SALES,
      'SUM_DENOMINATOR', a.SUM_PLACED_ORDERS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_PLACED_ORDERS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_MERCH_SALES,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_MERCH_SALES,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_PLACED_ORDERS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_PLACED_ORDERS,
      'VARIANCE_NUMERATOR', a.VARIANCE_MERCH_SALES,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_MERCH_SALES,
      'VARIANCE_DENOMINATOR', a.VARIANCE_PLACED_ORDERS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_PLACED_ORDERS,
      'STDDEV_NUMERATOR', a.STDDEV_MERCH_SALES,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_MERCH_SALES,
      'STDDEV_DENOMINATOR', a.STDDEV_PLACED_ORDERS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_PLACED_ORDERS,
      'COV', a.COV_MERCH_AOV,
      'CONTROL_COV', b.COV_MERCH_AOV
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'NET_CVR',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_UNCANCELLED_ORDERS_PLACED,
      'CONTROL_AVG_NUMERATOR', b.AVG_UNCANCELLED_ORDERS_PLACED,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_UNCANCELLED_ORDERS_PLACED,
      'CONTROL_SUM_NUMERATOR', b.SUM_UNCANCELLED_ORDERS_PLACED,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_UNCANCELLED_ORDERS_PLACED,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_UNCANCELLED_ORDERS_PLACED,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_UNCANCELLED_ORDERS_PLACED,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_UNCANCELLED_ORDERS_PLACED,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_UNCANCELLED_ORDERS_PLACED,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_UNCANCELLED_ORDERS_PLACED,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_NET_CVR,
      'CONTROL_COV', b.COV_NET_CVR
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'CHANGE_DATE_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_CHANGE_DATE_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_CHANGE_DATE_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_CHANGE_DATE_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_CHANGE_DATE_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_CHANGE_DATE_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_CHANGE_DATE_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_CHANGE_DATE_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_CHANGE_DATE_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_CHANGE_DATE_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_CHANGE_DATE_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_CHANGE_DATE_RATE,
      'CONTROL_COV', b.COV_CHANGE_DATE_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'INCREASE_FREQUENCY_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_INCREASE_FREQUENCY_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_INCREASE_FREQUENCY_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_CHANGE_FREQUENCY_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_CHANGE_FREQUENCY_SESSIONS,
      'SUM_NUMERATOR', a.SUM_INCREASE_FREQUENCY_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_INCREASE_FREQUENCY_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_CHANGE_FREQUENCY_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_CHANGE_FREQUENCY_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_INCREASE_FREQUENCY_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_INCREASE_FREQUENCY_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_CHANGE_FREQUENCY_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_CHANGE_FREQUENCY_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_INCREASE_FREQUENCY_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_INCREASE_FREQUENCY_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_CHANGE_FREQUENCY_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_CHANGE_FREQUENCY_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_INCREASE_FREQUENCY_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_INCREASE_FREQUENCY_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_CHANGE_FREQUENCY_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_CHANGE_FREQUENCY_SESSIONS,
      'COV', a.COV_INCREASE_FREQUENCY_RATE,
      'CONTROL_COV', b.COV_INCREASE_FREQUENCY_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'DECREASE_FREQUENCY_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_DECREASE_FREQUENCY_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_DECREASE_FREQUENCY_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_CHANGE_FREQUENCY_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_CHANGE_FREQUENCY_SESSIONS,
      'SUM_NUMERATOR', a.SUM_DECREASE_FREQUENCY_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_DECREASE_FREQUENCY_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_CHANGE_FREQUENCY_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_CHANGE_FREQUENCY_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_DECREASE_FREQUENCY_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_DECREASE_FREQUENCY_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_CHANGE_FREQUENCY_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_CHANGE_FREQUENCY_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_DECREASE_FREQUENCY_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_DECREASE_FREQUENCY_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_CHANGE_FREQUENCY_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_CHANGE_FREQUENCY_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_DECREASE_FREQUENCY_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_DECREASE_FREQUENCY_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_CHANGE_FREQUENCY_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_CHANGE_FREQUENCY_SESSIONS,
      'COV', a.COV_DECREASE_FREQUENCY_RATE,
      'CONTROL_COV', b.COV_DECREASE_FREQUENCY_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'REMOVE_ITEM_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ITEM_REMOVED_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ITEM_REMOVED_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ITEM_REMOVED_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ITEM_REMOVED_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ITEM_REMOVED_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ITEM_REMOVED_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ITEM_REMOVED_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ITEM_REMOVED_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ITEM_REMOVED_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ITEM_REMOVED_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_REMOVE_ITEM_RATE,
      'CONTROL_COV', b.COV_REMOVE_ITEM_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'SKIP_ITEM_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ITEM_SKIP_ORDER_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ITEM_SKIP_ORDER_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ITEM_SKIP_ORDER_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ITEM_SKIP_ORDER_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ITEM_SKIP_ORDER_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ITEM_SKIP_ORDER_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ITEM_SKIP_ORDER_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ITEM_SKIP_ORDER_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ITEM_SKIP_ORDER_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ITEM_SKIP_ORDER_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_SKIP_ITEM_RATE,
      'CONTROL_COV', b.COV_SKIP_ITEM_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'ATA_CONFIRMATION_PER_SESSION',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ATA_CONFIRMATIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ATA_CONFIRMATIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ATA_CONFIRMATIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ATA_CONFIRMATIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ATA_CONFIRMATIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ATA_CONFIRMATIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ATA_CONFIRMATIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ATA_CONFIRMATIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ATA_CONFIRMATIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ATA_CONFIRMATIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_ATA_CONFIRMATION_PER_SESSION,
      'CONTROL_COV', b.COV_ATA_CONFIRMATION_PER_SESSION
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'ATA_CONFIRMATION_PER_VISITOR',
      'metric_type', 'mean',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ATA_CONFIRMATIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ATA_CONFIRMATIONS,
      'SUM_NUMERATOR', a.SUM_ATA_CONFIRMATIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ATA_CONFIRMATIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ATA_CONFIRMATIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ATA_CONFIRMATIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ATA_CONFIRMATIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ATA_CONFIRMATIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ATA_CONFIRMATIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ATA_CONFIRMATIONS,
      'COV', a.COV_ATA_CONFIRMATION_PER_VISITOR,
      'CONTROL_COV', b.COV_ATA_CONFIRMATION_PER_VISITOR
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'APP_FTUE_PUSH_ENABLEMENT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_FTUE_PUSH_ENABLED_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_FTUE_PUSH_ENABLED_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_FTUE_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_FTUE_SESSIONS,
      'SUM_NUMERATOR', a.SUM_FTUE_PUSH_ENABLED_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_FTUE_PUSH_ENABLED_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_FTUE_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_FTUE_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_FTUE_PUSH_ENABLED_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_FTUE_PUSH_ENABLED_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_FTUE_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_FTUE_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_FTUE_PUSH_ENABLED_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_FTUE_PUSH_ENABLED_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_FTUE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_FTUE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_FTUE_PUSH_ENABLED_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_FTUE_PUSH_ENABLED_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_FTUE_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_FTUE_SESSIONS,
      'COV', a.COV_APP_FTUE_PUSH_ENABLEMENT_RATE,
      'CONTROL_COV', b.COV_APP_FTUE_PUSH_ENABLEMENT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'APP_FTUE_PUSH_SKIP_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_FTUE_PUSH_SKIP_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_FTUE_PUSH_SKIP_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_FTUE_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_FTUE_SESSIONS,
      'SUM_NUMERATOR', a.SUM_FTUE_PUSH_SKIP_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_FTUE_PUSH_SKIP_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_FTUE_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_FTUE_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_FTUE_PUSH_SKIP_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_FTUE_PUSH_SKIP_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_FTUE_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_FTUE_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_FTUE_PUSH_SKIP_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_FTUE_PUSH_SKIP_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_FTUE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_FTUE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_FTUE_PUSH_SKIP_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_FTUE_PUSH_SKIP_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_FTUE_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_FTUE_SESSIONS,
      'COV', a.COV_APP_FTUE_PUSH_SKIP_RATE,
      'CONTROL_COV', b.COV_APP_FTUE_PUSH_SKIP_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'APP_FTUE_PUSH_DISABLEMENT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_FTUE_PUSH_DISABLED_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_FTUE_PUSH_DISABLED_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_FTUE_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_FTUE_SESSIONS,
      'SUM_NUMERATOR', a.SUM_FTUE_PUSH_DISABLED_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_FTUE_PUSH_DISABLED_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_FTUE_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_FTUE_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_FTUE_PUSH_DISABLED_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_FTUE_PUSH_DISABLED_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_FTUE_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_FTUE_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_FTUE_PUSH_DISABLED_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_FTUE_PUSH_DISABLED_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_FTUE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_FTUE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_FTUE_PUSH_DISABLED_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_FTUE_PUSH_DISABLED_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_FTUE_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_FTUE_SESSIONS,
      'COV', a.COV_APP_FTUE_PUSH_DISABLEMENT_RATE,
      'CONTROL_COV', b.COV_APP_FTUE_PUSH_DISABLEMENT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'APP_FTUE_PUSH_EXIT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_FTUE_PUSH_EXIT_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_FTUE_PUSH_EXIT_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_FTUE_NOTIFICATION_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_FTUE_NOTIFICATION_SESSIONS,
      'SUM_NUMERATOR', a.SUM_FTUE_PUSH_EXIT_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_FTUE_PUSH_EXIT_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_FTUE_NOTIFICATION_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_FTUE_NOTIFICATION_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_FTUE_PUSH_EXIT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_FTUE_PUSH_EXIT_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_FTUE_NOTIFICATION_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_FTUE_NOTIFICATION_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_FTUE_PUSH_EXIT_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_FTUE_PUSH_EXIT_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_FTUE_NOTIFICATION_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_FTUE_NOTIFICATION_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_FTUE_PUSH_EXIT_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_FTUE_PUSH_EXIT_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_FTUE_NOTIFICATION_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_FTUE_NOTIFICATION_SESSIONS,
      'COV', a.COV_APP_FTUE_PUSH_EXIT_RATE,
      'CONTROL_COV', b.COV_APP_FTUE_PUSH_EXIT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'APP_FTUE_EXIT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_FTUE_EXIT_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_FTUE_EXIT_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_FTUE_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_FTUE_SESSIONS,
      'SUM_NUMERATOR', a.SUM_FTUE_EXIT_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_FTUE_EXIT_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_FTUE_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_FTUE_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_FTUE_EXIT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_FTUE_EXIT_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_FTUE_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_FTUE_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_FTUE_EXIT_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_FTUE_EXIT_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_FTUE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_FTUE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_FTUE_EXIT_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_FTUE_EXIT_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_FTUE_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_FTUE_SESSIONS,
      'COV', a.COV_APP_FTUE_EXIT_RATE,
      'CONTROL_COV', b.COV_APP_FTUE_EXIT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'MAS_BIA_ATA_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_MAS_BIA_ADD_TO_AUTOSHIP_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_MAS_BIA_ATA_RATE,
      'CONTROL_COV', b.COV_MAS_BIA_ATA_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'MAS_ITEM_QUANTITY_CHANGE_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_MAS_ITEM_QUANTITY_CHANGE_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_MAS_ITEM_QUANTITY_CHANGE_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_MAS_ITEM_QUANTITY_CHANGE_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_MAS_ITEM_QUANTITY_CHANGE_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_MAS_ITEM_QUANTITY_CHANGE_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_MAS_ITEM_QUANTITY_CHANGE_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_MAS_ITEM_QUANTITY_CHANGE_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_MAS_ITEM_QUANTITY_CHANGE_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_MAS_ITEM_QUANTITY_CHANGE_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_MAS_ITEM_QUANTITY_CHANGE_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_MAS_ITEM_QUANTITY_CHANGE_RATE,
      'CONTROL_COV', b.COV_MAS_ITEM_QUANTITY_CHANGE_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'MAS_PROMO_APPLICATION_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_MAS_PROMO_APPLIED_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_MAS_PROMO_APPLIED_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_MAS_PROMO_APPLIED_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_MAS_PROMO_APPLIED_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_MAS_PROMO_APPLIED_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_MAS_PROMO_APPLIED_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_MAS_PROMO_APPLIED_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_MAS_PROMO_APPLIED_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_MAS_PROMO_APPLIED_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_MAS_PROMO_APPLIED_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_MAS_PROMO_APPLICATION_RATE,
      'CONTROL_COV', b.COV_MAS_PROMO_APPLICATION_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'MAS_REPLACE_ITEM_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_MAS_REPLACE_ITEM_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_MAS_REPLACE_ITEM_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_MAS_REPLACE_ITEM_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_MAS_REPLACE_ITEM_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_MAS_REPLACE_ITEM_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_MAS_REPLACE_ITEM_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_MAS_REPLACE_ITEM_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_MAS_REPLACE_ITEM_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_MAS_REPLACE_ITEM_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_MAS_REPLACE_ITEM_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_MAS_REPLACE_ITEM_RATE,
      'CONTROL_COV', b.COV_MAS_REPLACE_ITEM_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'MAS_ADD_MORE_ITEMS_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_MAS_ADD_MORE_ITEM_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_MAS_ADD_MORE_ITEM_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_MAS_ADD_MORE_ITEM_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_MAS_ADD_MORE_ITEM_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_MAS_ADD_MORE_ITEM_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_MAS_ADD_MORE_ITEM_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_MAS_ADD_MORE_ITEM_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_MAS_ADD_MORE_ITEM_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_MAS_ADD_MORE_ITEM_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_MAS_ADD_MORE_ITEM_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_MAS_ADD_MORE_ITEMS_RATE,
      'CONTROL_COV', b.COV_MAS_ADD_MORE_ITEMS_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'MAS_NO_MGMT_SESSION_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_MAS_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_MAS_SESSIONS,
      'SUM_NUMERATOR', a.SUM_MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_MAS_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_MAS_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_MAS_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_MAS_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_MAS_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_MAS_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_MAS_SESSION_NO_MGMT_ACTIONS_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_MAS_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_MAS_SESSIONS,
      'COV', a.COV_MAS_NO_MGMT_SESSION_RATE,
      'CONTROL_COV', b.COV_MAS_NO_MGMT_SESSION_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'BARK_BAR_CTR',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_BARK_BAR_CLICK_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_BARK_BAR_CLICK_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_BARK_BAR_IMPRESSION_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_BARK_BAR_IMPRESSION_SESSIONS,
      'SUM_NUMERATOR', a.SUM_BARK_BAR_CLICK_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_BARK_BAR_CLICK_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_BARK_BAR_IMPRESSION_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_BARK_BAR_IMPRESSION_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_BARK_BAR_CLICK_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_BARK_BAR_CLICK_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_BARK_BAR_IMPRESSION_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_BARK_BAR_IMPRESSION_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_BARK_BAR_CLICK_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_BARK_BAR_CLICK_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_BARK_BAR_IMPRESSION_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_BARK_BAR_IMPRESSION_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_BARK_BAR_CLICK_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_BARK_BAR_CLICK_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_BARK_BAR_IMPRESSION_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_BARK_BAR_IMPRESSION_SESSIONS,
      'COV', a.COV_BARK_BAR_CTR,
      'CONTROL_COV', b.COV_BARK_BAR_CTR
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'BARK_BAR_CLICKSHARE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_BARK_BAR_CLICK_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_BARK_BAR_CLICK_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_HOME_PAGE_CLICKS_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_HOME_PAGE_CLICKS_SESSIONS,
      'SUM_NUMERATOR', a.SUM_BARK_BAR_CLICK_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_BARK_BAR_CLICK_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_HOME_PAGE_CLICKS_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_HOME_PAGE_CLICKS_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_BARK_BAR_CLICK_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_BARK_BAR_CLICK_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_HOME_PAGE_CLICKS_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_HOME_PAGE_CLICKS_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_BARK_BAR_CLICK_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_BARK_BAR_CLICK_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_HOME_PAGE_CLICKS_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_HOME_PAGE_CLICKS_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_BARK_BAR_CLICK_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_BARK_BAR_CLICK_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_HOME_PAGE_CLICKS_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_HOME_PAGE_CLICKS_SESSIONS,
      'COV', a.COV_BARK_BAR_CLICKSHARE,
      'CONTROL_COV', b.COV_BARK_BAR_CLICKSHARE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'ORDER_CCP',
      'metric_type', 'mean',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ORDER_CCP,
      'CONTROL_AVG_NUMERATOR', b.AVG_ORDER_CCP,
      'SUM_NUMERATOR', a.SUM_ORDER_CCP,
      'CONTROL_SUM_NUMERATOR', b.SUM_ORDER_CCP,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ORDER_CCP,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ORDER_CCP,
      'VARIANCE_NUMERATOR', a.VARIANCE_ORDER_CCP,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ORDER_CCP,
      'STDDEV_NUMERATOR', a.STDDEV_ORDER_CCP,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ORDER_CCP,
      'COV', a.COV_ORDER_CCP,
      'CONTROL_COV', b.COV_ORDER_CCP
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'ORDER_PER_PURCHASER',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_PLACED_ORDERS,
      'CONTROL_AVG_NUMERATOR', b.AVG_PLACED_ORDERS,
      'AVG_DENOMINATOR', a.AVG_PURCHASE_FLAG,
      'CONTROL_AVG_DENOMINATOR', b.AVG_PURCHASE_FLAG,
      'SUM_NUMERATOR', a.SUM_PLACED_ORDERS,
      'CONTROL_SUM_NUMERATOR', b.SUM_PLACED_ORDERS,
      'SUM_DENOMINATOR', a.SUM_PURCHASE_FLAG,
      'CONTROL_SUM_DENOMINATOR', b.SUM_PURCHASE_FLAG,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_PLACED_ORDERS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_PLACED_ORDERS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_PURCHASE_FLAG,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_PURCHASE_FLAG,
      'VARIANCE_NUMERATOR', a.VARIANCE_PLACED_ORDERS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_PLACED_ORDERS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_PURCHASE_FLAG,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_PURCHASE_FLAG,
      'STDDEV_NUMERATOR', a.STDDEV_PLACED_ORDERS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_PLACED_ORDERS,
      'STDDEV_DENOMINATOR', a.STDDEV_PURCHASE_FLAG,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_PURCHASE_FLAG,
      'COV', a.COV_ORDER_PER_PURCHASER,
      'CONTROL_COV', b.COV_ORDER_PER_PURCHASER
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'NET_SALES_PER_VISITOR',
      'metric_type', 'mean',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_NET_SALES,
      'CONTROL_AVG_NUMERATOR', b.AVG_NET_SALES,
      'SUM_NUMERATOR', a.SUM_NET_SALES,
      'CONTROL_SUM_NUMERATOR', b.SUM_NET_SALES,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_NET_SALES,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_NET_SALES,
      'VARIANCE_NUMERATOR', a.VARIANCE_NET_SALES,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_NET_SALES,
      'STDDEV_NUMERATOR', a.STDDEV_NET_SALES,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_NET_SALES,
      'COV', a.COV_NET_SALES_PER_VISITOR,
      'CONTROL_COV', b.COV_NET_SALES_PER_VISITOR
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'NET_SALES_PER_SESSION',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_NET_SALES,
      'CONTROL_AVG_NUMERATOR', b.AVG_NET_SALES,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_NET_SALES,
      'CONTROL_SUM_NUMERATOR', b.SUM_NET_SALES,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_NET_SALES,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_NET_SALES,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_NET_SALES,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_NET_SALES,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_NET_SALES,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_NET_SALES,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_NET_SALES_PER_SESSION,
      'CONTROL_COV', b.COV_NET_SALES_PER_SESSION
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'ORDER_CANCELLATION_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_CHECKOUT_CANCELLED_ORDERS,
      'CONTROL_AVG_NUMERATOR', b.AVG_CHECKOUT_CANCELLED_ORDERS,
      'AVG_DENOMINATOR', a.AVG_PLACED_ORDERS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_PLACED_ORDERS,
      'SUM_NUMERATOR', a.SUM_CHECKOUT_CANCELLED_ORDERS,
      'CONTROL_SUM_NUMERATOR', b.SUM_CHECKOUT_CANCELLED_ORDERS,
      'SUM_DENOMINATOR', a.SUM_PLACED_ORDERS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_PLACED_ORDERS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_CHECKOUT_CANCELLED_ORDERS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_CHECKOUT_CANCELLED_ORDERS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_PLACED_ORDERS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_PLACED_ORDERS,
      'VARIANCE_NUMERATOR', a.VARIANCE_CHECKOUT_CANCELLED_ORDERS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_CHECKOUT_CANCELLED_ORDERS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_PLACED_ORDERS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_PLACED_ORDERS,
      'STDDEV_NUMERATOR', a.STDDEV_CHECKOUT_CANCELLED_ORDERS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_CHECKOUT_CANCELLED_ORDERS,
      'STDDEV_DENOMINATOR', a.STDDEV_PLACED_ORDERS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_PLACED_ORDERS,
      'COV', a.COV_ORDER_CANCELLATION_RATE,
      'CONTROL_COV', b.COV_ORDER_CANCELLATION_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'MAS_ORDER_NOW_EDIT_PAYMENT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ORDER_NOW_EDIT_PAYMENT_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ORDER_NOW_EDIT_PAYMENT_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ORDER_NOW_EDIT_PAYMENT_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ORDER_NOW_EDIT_PAYMENT_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ORDER_NOW_EDIT_PAYMENT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ORDER_NOW_EDIT_PAYMENT_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ORDER_NOW_EDIT_PAYMENT_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ORDER_NOW_EDIT_PAYMENT_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ORDER_NOW_EDIT_PAYMENT_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ORDER_NOW_EDIT_PAYMENT_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_MAS_ORDER_NOW_EDIT_PAYMENT_RATE,
      'CONTROL_COV', b.COV_MAS_ORDER_NOW_EDIT_PAYMENT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'MAS_ORDER_NOW_EDIT_ADDRESS_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_ORDER_NOW_EDIT_ADDRESS_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_ORDER_NOW_EDIT_ADDRESS_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_ORDER_NOW_EDIT_ADDRESS_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_ORDER_NOW_EDIT_ADDRESS_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_ORDER_NOW_EDIT_ADDRESS_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_ORDER_NOW_EDIT_ADDRESS_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_ORDER_NOW_EDIT_ADDRESS_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_ORDER_NOW_EDIT_ADDRESS_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_ORDER_NOW_EDIT_ADDRESS_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_ORDER_NOW_EDIT_ADDRESS_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_MAS_ORDER_NOW_EDIT_ADDRESS_RATE,
      'CONTROL_COV', b.COV_MAS_ORDER_NOW_EDIT_ADDRESS_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'HOMEPAGE_BOUNCE_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_HOME_BOUNCE_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_HOME_BOUNCE_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_HOMEPAGE_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_HOMEPAGE_SESSIONS,
      'SUM_NUMERATOR', a.SUM_HOME_BOUNCE_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_HOME_BOUNCE_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_HOMEPAGE_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_HOMEPAGE_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_HOME_BOUNCE_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_HOME_BOUNCE_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_HOMEPAGE_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_HOMEPAGE_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_HOME_BOUNCE_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_HOME_BOUNCE_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_HOMEPAGE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_HOMEPAGE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_HOME_BOUNCE_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_HOME_BOUNCE_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_HOMEPAGE_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_HOMEPAGE_SESSIONS,
      'COV', a.COV_HOMEPAGE_BOUNCE_RATE,
      'CONTROL_COV', b.COV_HOMEPAGE_BOUNCE_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'HOMEPAGE_EXIT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_HOME_EXIT_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_HOME_EXIT_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_HOMEPAGE_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_HOMEPAGE_SESSIONS,
      'SUM_NUMERATOR', a.SUM_HOME_EXIT_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_HOME_EXIT_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_HOMEPAGE_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_HOMEPAGE_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_HOME_EXIT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_HOME_EXIT_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_HOMEPAGE_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_HOMEPAGE_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_HOME_EXIT_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_HOME_EXIT_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_HOMEPAGE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_HOMEPAGE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_HOME_EXIT_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_HOME_EXIT_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_HOMEPAGE_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_HOMEPAGE_SESSIONS,
      'COV', a.COV_HOMEPAGE_EXIT_RATE,
      'CONTROL_COV', b.COV_HOMEPAGE_EXIT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'HOMEPAGE_SESSIONS_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_HOMEPAGE_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_HOMEPAGE_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_HOMEPAGE_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_HOMEPAGE_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_HOMEPAGE_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_HOMEPAGE_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_HOMEPAGE_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_HOMEPAGE_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_HOMEPAGE_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_HOMEPAGE_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_HOMEPAGE_SESSIONS_RATE,
      'CONTROL_COV', b.COV_HOMEPAGE_SESSIONS_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'CART_VISIT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_CART_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_CART_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_CART_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_CART_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_CART_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_CART_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_CART_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_CART_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_CART_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_CART_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_CART_VISIT_RATE,
      'CONTROL_COV', b.COV_CART_VISIT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'DISTINCT_HOMEPAGE_WIDGETS',
      'metric_type', 'mean',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_HOMEPAGE_DISTINCT_WIDGETS,
      'CONTROL_AVG_NUMERATOR', b.AVG_HOMEPAGE_DISTINCT_WIDGETS,
      'SUM_NUMERATOR', a.SUM_HOMEPAGE_DISTINCT_WIDGETS,
      'CONTROL_SUM_NUMERATOR', b.SUM_HOMEPAGE_DISTINCT_WIDGETS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_HOMEPAGE_DISTINCT_WIDGETS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_HOMEPAGE_DISTINCT_WIDGETS,
      'VARIANCE_NUMERATOR', a.VARIANCE_HOMEPAGE_DISTINCT_WIDGETS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_HOMEPAGE_DISTINCT_WIDGETS,
      'STDDEV_NUMERATOR', a.STDDEV_HOMEPAGE_DISTINCT_WIDGETS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_HOMEPAGE_DISTINCT_WIDGETS,
      'COV', a.COV_DISTINCT_HOMEPAGE_WIDGETS,
      'CONTROL_COV', b.COV_DISTINCT_HOMEPAGE_WIDGETS
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'HOMEPAGE_BRAND_PM_IMPRESSIONS',
      'metric_type', 'mean',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_HOMEPAGE_BRAND_PM_IMPRESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_HOMEPAGE_BRAND_PM_IMPRESSIONS,
      'SUM_NUMERATOR', a.SUM_HOMEPAGE_BRAND_PM_IMPRESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_HOMEPAGE_BRAND_PM_IMPRESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_HOMEPAGE_BRAND_PM_IMPRESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_HOMEPAGE_BRAND_PM_IMPRESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_HOMEPAGE_BRAND_PM_IMPRESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_HOMEPAGE_BRAND_PM_IMPRESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_HOMEPAGE_BRAND_PM_IMPRESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_HOMEPAGE_BRAND_PM_IMPRESSIONS,
      'COV', a.COV_HOMEPAGE_BRAND_PM_IMPRESSIONS,
      'CONTROL_COV', b.COV_HOMEPAGE_BRAND_PM_IMPRESSIONS
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'HOMEPAGE_CVR',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_UNCANCELLED_ORDERS_PLACED,
      'CONTROL_AVG_NUMERATOR', b.AVG_UNCANCELLED_ORDERS_PLACED,
      'AVG_DENOMINATOR', a.AVG_HOME_PAGE_CLICKS_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_HOME_PAGE_CLICKS_SESSIONS,
      'SUM_NUMERATOR', a.SUM_UNCANCELLED_ORDERS_PLACED,
      'CONTROL_SUM_NUMERATOR', b.SUM_UNCANCELLED_ORDERS_PLACED,
      'SUM_DENOMINATOR', a.SUM_HOME_PAGE_CLICKS_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_HOME_PAGE_CLICKS_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_UNCANCELLED_ORDERS_PLACED,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_UNCANCELLED_ORDERS_PLACED,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_HOME_PAGE_CLICKS_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_HOME_PAGE_CLICKS_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_UNCANCELLED_ORDERS_PLACED,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_UNCANCELLED_ORDERS_PLACED,
      'VARIANCE_DENOMINATOR', a.VARIANCE_HOME_PAGE_CLICKS_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_HOME_PAGE_CLICKS_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_UNCANCELLED_ORDERS_PLACED,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_UNCANCELLED_ORDERS_PLACED,
      'STDDEV_DENOMINATOR', a.STDDEV_HOME_PAGE_CLICKS_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_HOME_PAGE_CLICKS_SESSIONS,
      'COV', a.COV_HOMEPAGE_CVR,
      'CONTROL_COV', b.COV_HOMEPAGE_CVR
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'APP_FIRST_ORDER_VISITOR_CVR',
      'metric_type', 'rate',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_UNCANCELLED_FIRST_APP_ORDERS_PLACED,
      'CONTROL_AVG_NUMERATOR', b.AVG_UNCANCELLED_FIRST_APP_ORDERS_PLACED,
      'AVG_DENOMINATOR', a.AVG_NEW_TO_APP_ORDER_FLAG,
      'CONTROL_AVG_DENOMINATOR', b.AVG_NEW_TO_APP_ORDER_FLAG,
      'SUM_NUMERATOR', a.SUM_UNCANCELLED_FIRST_APP_ORDERS_PLACED,
      'CONTROL_SUM_NUMERATOR', b.SUM_UNCANCELLED_FIRST_APP_ORDERS_PLACED,
      'SUM_DENOMINATOR', a.SUM_NEW_TO_APP_ORDER_FLAG,
      'CONTROL_SUM_DENOMINATOR', b.SUM_NEW_TO_APP_ORDER_FLAG,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_UNCANCELLED_FIRST_APP_ORDERS_PLACED,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_UNCANCELLED_FIRST_APP_ORDERS_PLACED,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_NEW_TO_APP_ORDER_FLAG,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_NEW_TO_APP_ORDER_FLAG,
      'VARIANCE_NUMERATOR', a.VARIANCE_UNCANCELLED_FIRST_APP_ORDERS_PLACED,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_UNCANCELLED_FIRST_APP_ORDERS_PLACED,
      'VARIANCE_DENOMINATOR', a.VARIANCE_NEW_TO_APP_ORDER_FLAG,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_NEW_TO_APP_ORDER_FLAG,
      'STDDEV_NUMERATOR', a.STDDEV_UNCANCELLED_FIRST_APP_ORDERS_PLACED,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_UNCANCELLED_FIRST_APP_ORDERS_PLACED,
      'STDDEV_DENOMINATOR', a.STDDEV_NEW_TO_APP_ORDER_FLAG,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_NEW_TO_APP_ORDER_FLAG,
      'COV', a.COV_APP_FIRST_ORDER_VISITOR_CVR,
      'CONTROL_COV', b.COV_APP_FIRST_ORDER_VISITOR_CVR
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'PET_PORTAL_VISIT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_PET_PORTAL_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_PET_PORTAL_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_PET_PORTAL_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_PET_PORTAL_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_PET_PORTAL_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_PET_PORTAL_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_PET_PORTAL_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_PET_PORTAL_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_PET_PORTAL_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_PET_PORTAL_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_PET_PORTAL_VISIT_RATE,
      'CONTROL_COV', b.COV_PET_PORTAL_VISIT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'CAREPLUS_VISIT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_CAREPLUS_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_CAREPLUS_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_CAREPLUS_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_CAREPLUS_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_CAREPLUS_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_CAREPLUS_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_CAREPLUS_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_CAREPLUS_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_CAREPLUS_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_CAREPLUS_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_CAREPLUS_VISIT_RATE,
      'CONTROL_COV', b.COV_CAREPLUS_VISIT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'CWAV_VISIT_RATE',
      'metric_type', 'ratio',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_CWAV_SESSIONS,
      'CONTROL_AVG_NUMERATOR', b.AVG_CWAV_SESSIONS,
      'AVG_DENOMINATOR', a.AVG_SESSIONS,
      'CONTROL_AVG_DENOMINATOR', b.AVG_SESSIONS,
      'SUM_NUMERATOR', a.SUM_CWAV_SESSIONS,
      'CONTROL_SUM_NUMERATOR', b.SUM_CWAV_SESSIONS,
      'SUM_DENOMINATOR', a.SUM_SESSIONS,
      'CONTROL_SUM_DENOMINATOR', b.SUM_SESSIONS,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_CWAV_SESSIONS,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_CWAV_SESSIONS,
      'COUNT_DISTINCT_DENOMINATOR', a.COUNT_DISTINCT_SESSIONS,
      'CONTROL_COUNT_DISTINCT_DENOMINATOR', b.COUNT_DISTINCT_SESSIONS,
      'VARIANCE_NUMERATOR', a.VARIANCE_CWAV_SESSIONS,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_CWAV_SESSIONS,
      'VARIANCE_DENOMINATOR', a.VARIANCE_SESSIONS,
      'CONTROL_VARIANCE_DENOMINATOR', b.VARIANCE_SESSIONS,
      'STDDEV_NUMERATOR', a.STDDEV_CWAV_SESSIONS,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_CWAV_SESSIONS,
      'STDDEV_DENOMINATOR', a.STDDEV_SESSIONS,
      'CONTROL_STDDEV_DENOMINATOR', b.STDDEV_SESSIONS,
      'COV', a.COV_CWAV_VISIT_RATE,
      'CONTROL_COV', b.COV_CWAV_VISIT_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'PET_PROFILE_CREATION_RATE',
      'metric_type', 'mean',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_PET_PROFILE_CREATION_COUNT,
      'CONTROL_AVG_NUMERATOR', b.AVG_PET_PROFILE_CREATION_COUNT,
      'SUM_NUMERATOR', a.SUM_PET_PROFILE_CREATION_COUNT,
      'CONTROL_SUM_NUMERATOR', b.SUM_PET_PROFILE_CREATION_COUNT,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_PET_PROFILE_CREATION_COUNT,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_PET_PROFILE_CREATION_COUNT,
      'VARIANCE_NUMERATOR', a.VARIANCE_PET_PROFILE_CREATION_COUNT,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_PET_PROFILE_CREATION_COUNT,
      'STDDEV_NUMERATOR', a.STDDEV_PET_PROFILE_CREATION_COUNT,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_PET_PROFILE_CREATION_COUNT,
      'COV', a.COV_PET_PROFILE_CREATION_RATE,
      'CONTROL_COV', b.COV_PET_PROFILE_CREATION_RATE
    ),
    OBJECT_CONSTRUCT_KEEP_NULL(
      'metric', 'PET_PHOTO_UPLOAD_RATE',
      'metric_type', 'mean',
      'VISITOR_COUNT', a.visitor_count,
      'CONTROL_VISITOR_COUNT', b.visitor_count,
      'AVG_NUMERATOR', a.AVG_PET_PHOTO_UPLOAD_COUNT,
      'CONTROL_AVG_NUMERATOR', b.AVG_PET_PHOTO_UPLOAD_COUNT,
      'SUM_NUMERATOR', a.SUM_PET_PHOTO_UPLOAD_COUNT,
      'CONTROL_SUM_NUMERATOR', b.SUM_PET_PHOTO_UPLOAD_COUNT,
      'COUNT_DISTINCT_NUMERATOR', a.COUNT_DISTINCT_PET_PHOTO_UPLOAD_COUNT,
      'CONTROL_COUNT_DISTINCT_NUMERATOR', b.COUNT_DISTINCT_PET_PHOTO_UPLOAD_COUNT,
      'VARIANCE_NUMERATOR', a.VARIANCE_PET_PHOTO_UPLOAD_COUNT,
      'CONTROL_VARIANCE_NUMERATOR', b.VARIANCE_PET_PHOTO_UPLOAD_COUNT,
      'STDDEV_NUMERATOR', a.STDDEV_PET_PHOTO_UPLOAD_COUNT,
      'CONTROL_STDDEV_NUMERATOR', b.STDDEV_PET_PHOTO_UPLOAD_COUNT,
      'COV', a.COV_PET_PHOTO_UPLOAD_RATE,
      'CONTROL_COV', b.COV_PET_PHOTO_UPLOAD_RATE
    )
  ) AS metrics_array
from TEMP_TEST_METRICS_level_1 a, TEMP_TEST_METRICS_level_1 b
where a.EXPERIMENT = b.EXPERIMENT AND lower(a.VARIATION) NOT IN ('control', 'false') AND lower(b.VARIATION) IN ('control', 'false')
)
select
  t.data_date,
  t.groupingset_name,
  t.src_file,
  t.EXPERIMENT,
  t.VARIATION,
  t.variation_cnt,
  t.SIGNIFICANCE,
  metric.value:AVG_DENOMINATOR::FLOAT AS avg_denominator,
  metric.value:AVG_NUMERATOR::FLOAT AS avg_numerator,
  metric.value:CONTROL_AVG_DENOMINATOR::FLOAT AS control_avg_denominator,
  metric.value:CONTROL_AVG_NUMERATOR::FLOAT AS control_avg_numerator,
  metric.value:CONTROL_COUNT_DISTINCT_DENOMINATOR::INTEGER AS control_count_distinct_denominator,
  metric.value:CONTROL_COUNT_DISTINCT_NUMERATOR::INTEGER AS control_count_distinct_numerator,
  metric.value:CONTROL_COV::FLOAT AS control_cov,
  metric.value:CONTROL_STDDEV_DENOMINATOR::FLOAT AS control_stddev_denominator,
  metric.value:CONTROL_STDDEV_NUMERATOR::FLOAT AS control_stddev_numerator,
  metric.value:CONTROL_SUM_DENOMINATOR::FLOAT AS control_sum_denominator,
  metric.value:CONTROL_SUM_NUMERATOR::FLOAT AS control_sum_numerator,
  metric.value:CONTROL_VARIANCE_DENOMINATOR::FLOAT AS control_variance_denominator,
  metric.value:CONTROL_VARIANCE_NUMERATOR::FLOAT AS control_variance_numerator,
  metric.value:CONTROL_VISITOR_COUNT::INTEGER AS control_visitor_count,
  metric.value:COUNT_DISTINCT_DENOMINATOR::INTEGER AS count_distinct_denominator,
  metric.value:COUNT_DISTINCT_NUMERATOR::INTEGER AS count_distinct_numerator,
  metric.value:COV::FLOAT AS cov,
  metric.value:STDDEV_DENOMINATOR::FLOAT AS stddev_denominator,
  metric.value:STDDEV_NUMERATOR::FLOAT AS stddev_numerator,
  metric.value:SUM_DENOMINATOR::FLOAT AS sum_denominator,
  metric.value:SUM_NUMERATOR::FLOAT AS sum_numerator,
  metric.value:VARIANCE_DENOMINATOR::FLOAT AS variance_denominator,
  metric.value:VARIANCE_NUMERATOR::FLOAT AS variance_numerator,
  metric.value:VISITOR_COUNT::INTEGER AS visitor_count,
  metric.value:metric::STRING AS metric_name,
  metric.value:metric_type::STRING AS metric_type
from pairwise_json t,
  LATERAL FLATTEN(input => t.metrics_array) AS metric
;


create or replace local temp table ms_exp_results_raw as
with exp_config as (
    -- Get GST config from experiment metadata
    SELECT
        g.EXPERIMENT_NAME,
        COALESCE(g.NUM_OF_CHECKPOINTS, 1) AS NUM_OF_CHECKPOINTS,
        COALESCE(g.SEQUENTIAL_OPTION, FALSE) AS SEQUENTIAL_OPTION,
        g.TEST_DURATION,
        (g.TEST_DURATION * 7) + 1 AS TOTAL_TEST_DAYS,
        d.START_DATE
    FROM BT_SITE_ANALYTICS.EXPLT_EXPERIMENT_METADATA g
    LEFT JOIN ECOM_SANDBOX.EXP_DETAILS d
        ON UPPER(g.EXPERIMENT_NAME) = UPPER(d.EXPERIMENT_NAME)
    WHERE g.TEST_DURATION IS NOT NULL
      AND g.TEST_DURATION > 0
      and g.experiment_name = '2026_04_DISCOVERY_SEARCH_REDIRECT_REMOVALS'
),

gst_function as (
select 'full' AS LOAD_TYPE,
    'ALL' AS METRIC_PROPERTIES,
    'ALL' AS METRIC_PROPERTY_VALUES,
    'ALL' AS ENTITY_PROPERTIES,
    'ALL' AS ENTITY_PROPERTY_VALUES,
    *,
CASE
                WHEN e.SEQUENTIAL_OPTION = TRUE
                     AND e.TOTAL_TEST_DAYS IS NOT NULL
                     AND e.TOTAL_TEST_DAYS > 0
                     AND (CASE
                             WHEN e.TOTAL_TEST_DAYS IS NOT NULL AND e.TOTAL_TEST_DAYS > 0 AND e.START_DATE IS NOT NULL
                             THEN LEAST(DATEDIFF('day', e.START_DATE, $data_date)::FLOAT / e.TOTAL_TEST_DAYS, 1.0)
                             ELSE NULL
                          END) IS NOT NULL
                THEN e.NUM_OF_CHECKPOINTS
                ELSE NULL
            END  NUM_CHECKPOINTS,
            CASE
                WHEN e.SEQUENTIAL_OPTION = TRUE
                     AND e.TOTAL_TEST_DAYS IS NOT NULL
                     AND e.TOTAL_TEST_DAYS > 0
                     AND (CASE
                             WHEN e.TOTAL_TEST_DAYS IS NOT NULL AND e.TOTAL_TEST_DAYS > 0 AND e.START_DATE IS NOT NULL
                             THEN LEAST(DATEDIFF('day', e.START_DATE, $data_date)::FLOAT / e.TOTAL_TEST_DAYS, 1.0)
                             ELSE NULL
                          END) IS NOT NULL
                THEN (CASE
                         WHEN e.TOTAL_TEST_DAYS IS NOT NULL AND e.TOTAL_TEST_DAYS > 0 AND e.START_DATE IS NOT NULL
                         THEN LEAST(DATEDIFF('day', e.START_DATE, $data_date)::FLOAT / e.TOTAL_TEST_DAYS, 1.0)
                         ELSE NULL
                      END)
                ELSE NULL
            END  INFO_FRACTION_INPUT
FROM TEMP_MS_EXP_METRICS_LEVEL_2 m
    LEFT JOIN exp_config e ON UPPER(m.EXPERIMENT) = UPPER(e.EXPERIMENT_NAME)
    WHERE m.DATA_DATE = $data_date)

, results as (
    SELECT m.* EXCLUDE (METRIC_PROPERTIES),
        case when m.METRIC_PROPERTIES = 'PRODUCT_MERCH_CLASSIFICATION1' then 'MC1'
             when m.METRIC_PROPERTIES = 'PRODUCT_MERCH_CLASSIFICATION1,PRODUCT_MERCH_CLASSIFICATION2' then 'MC1,MC2'
        else m.METRIC_PROPERTIES end as METRIC_PROPERTIES,
        ms_calc_delta_ttest_hx(
            m.METRIC_TYPE,
            m.CONTROL_AVG_NUMERATOR,
            m.CONTROL_AVG_DENOMINATOR,
            m.CONTROL_VARIANCE_NUMERATOR,
            m.CONTROL_VARIANCE_DENOMINATOR,
            m.CONTROL_COV,
            m.CONTROL_SUM_NUMERATOR,
            m.CONTROL_SUM_DENOMINATOR,
            m.AVG_NUMERATOR,
            m.AVG_DENOMINATOR,
            m.VARIANCE_NUMERATOR,
            m.VARIANCE_DENOMINATOR,
            m.COV,
            m.SUM_NUMERATOR,
            m.SUM_DENOMINATOR,
            m.CONTROL_VISITOR_COUNT,
            m.VISITOR_COUNT,
            m.SIGNIFICANCE,
            NUM_CHECKPOINTS,
            INFO_FRACTION_INPUT
        )  metric_results
    FROM gst_function m )

select *,
  -- Fixed-horizon results (always present)
  metric_results:"control_mean"::FLOAT AS control_mean,
  metric_results:"variant_mean"::FLOAT AS variant_mean,
  metric_results:"control_var"::FLOAT AS control_var,
  metric_results:"variant_var"::FLOAT AS variant_var,
  metric_results:"delta"::FLOAT AS delta,
  metric_results:"p_value"::FLOAT AS p_value,
  metric_results:"z_score"::FLOAT AS z_score,
  metric_results:"upper_ci"::FLOAT AS upper_ci,
  metric_results:"lower_ci"::FLOAT AS lower_ci,
  -- GST results (always populated when SEQUENTIAL_OPTION = TRUE and GST parameters provided)
  metric_results:"checkpoint_k"::INTEGER AS checkpoint_k,
  metric_results:"info_fraction"::FLOAT AS info_fraction,
  metric_results:"z_critical_gst"::FLOAT AS z_critical_gst,
  metric_results:"upper_ci_gst"::FLOAT AS upper_ci_gst,
  metric_results:"lower_ci_gst"::FLOAT AS lower_ci_gst,
  metric_results:"significance_gst"::FLOAT AS significance_gst,
--   metric_results:"decision_gst"::STRING AS decision_gst,
  -- metric_results:"rejected_gst"::INTEGER::BOOLEAN AS rejected_gst
from results
;

create or replace local temp table ms_exp_results_final as
WITH input_data AS (
    -- Replace this with your actual table/query that contains p_values
    SELECT
        data_date,
        p_value, -- made up values
        experiment, -- Grouping columns as needed
        metric_name,
        groupingset_name,
        variation,
        ENTITY_PROPERTIES,
        ENTITY_PROPERTY_VALUES,
        METRIC_PROPERTIES,
        METRIC_PROPERTY_VALUES
    FROM ms_exp_results_raw
    where groupingset_name <> 'ALL'
        and p_value IS NOT NULL  -- Filter out null p-values
),
-- Step 1: Calculate FDR level (Q) based on number of tests per group
group_stats AS (
    SELECT
        experiment,
        metric_name,
        groupingset_name,
        COUNT(*) as m,  -- Number of valid p-values
        CASE
            WHEN COUNT(*) <= 4 THEN 0.08
            WHEN COUNT(*) < 8 THEN 0.12
            ELSE 0.25
        END as q
    FROM input_data
    GROUP BY experiment, metric_name, groupingset_name
),

-- Step 2: Rank p-values within each group
ranked_data AS (
    SELECT
        i.*,
        g.m,
        g.q,
        ROW_NUMBER() OVER (
            PARTITION BY i.experiment, i.metric_name, i.groupingset_name
            ORDER BY i.p_value
        ) as rank_within_group
    FROM input_data i
    JOIN group_stats g ON
        i.experiment = g.experiment AND
        i.metric_name = g.metric_name AND
        i.groupingset_name = g.groupingset_name
),

-- Step 3: Calculate BH critical values
bh_critical_calc AS (
    SELECT
        *,
        (rank_within_group::FLOAT / m) * q as bh_critical,
        CASE
            WHEN p_value <= (rank_within_group::FLOAT / m) * q THEN TRUE
            ELSE FALSE
        END as bh_rejected
    FROM ranked_data
),

-- Step 4: Find the maximum index where p_value <= bh_critical
max_rejected_rank AS (
    SELECT
        experiment,
        metric_name,
        groupingset_name,
        MAX(CASE WHEN bh_rejected THEN rank_within_group ELSE 0 END) as max_rejected_rank
    FROM bh_critical_calc
    GROUP BY experiment, metric_name, groupingset_name
),

-- Step 5: Determine final rejection status and decision
final_results AS (
    SELECT
        b.*,
        CASE
            WHEN b.rank_within_group <= m.max_rejected_rank THEN 'CONCLUSIVE'
            ELSE 'INCONCLUSIVE'
        END as bh_decision
    FROM bh_critical_calc b
    JOIN max_rejected_rank m ON
        b.experiment = m.experiment AND
        b.metric_name = m.metric_name AND
        b.groupingset_name = m.groupingset_name
)

-- Final output
SELECT
    a.* ,
    bh_critical,
    bh_rejected,
    bh_decision,
    case when a.p_value is null then 'NA'
         when a.groupingset_name = 'ALL' and a.p_value <= significance and delta > 0 then 'POSITIVE'
         when a.groupingset_name = 'ALL' and a.p_value <= significance and DELTA < 0 then 'NEGATIVE'
         when a.groupingset_name = 'ALL' and a.p_value > significance then 'INCONCLUSIVE'
         when a.groupingset_name <> 'ALL' and bh_decision = 'CONCLUSIVE' and DELTA > 0 then 'POSITIVE'
         when a.groupingset_name <> 'ALL' and bh_decision = 'CONCLUSIVE' and DELTA < 0 then 'NEGATIVE'
         when a.groupingset_name <> 'ALL' and bh_decision <> 'CONCLUSIVE' then 'INCONCLUSIVE' end as decision,
    case when a.p_value is null then 'NA'
         when a.groupingset_name = 'ALL' and a.p_value <= significance_gst and delta > 0 then 'POSITIVE'
         when a.groupingset_name = 'ALL' and a.p_value <= significance_gst and DELTA < 0 then 'NEGATIVE'
         when a.groupingset_name = 'ALL' and a.p_value > significance_gst then 'INCONCLUSIVE'
         when a.groupingset_name <> 'ALL' THEN NULL
        end as decision_gst
FROM ms_exp_results_raw a
    left join final_results b on
        a.experiment = b.experiment AND
        a.variation = b.variation AND
        a.metric_name = b.metric_name AND
        a.groupingset_name = b.groupingset_name AND
        a.entity_properties = b.entity_properties and
        a.entity_property_values = b.entity_property_values and
        a.metric_properties = b.metric_properties and
        a.metric_property_values = b.metric_property_values
where a.data_date = $data_date
;

select
experiment,
variation,
metric_name,
control_visitor_count,
visitor_count as variant_visitor_count,
control_mean,
variant_mean,
delta,
div0(delta,control_mean) as pct_change,
lower_ci,
upper_ci,
p_value,
decision
from MS_EXP_RESULTS_FINAL
where metric_name in ('CVR','CCV','MERCH_SALES_PER_SESSION','NET_UPO','MERCH_AOV','AD_ROAS_24H','AD_CTR','AD_ROAS_24H','MERCH_SALES_PER_VISITOR','ADS_REVENUE_PER_SESSION','AD_CVR_24H')
;
