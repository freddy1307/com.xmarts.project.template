-- View: apm_payment_v

-- DROP VIEW apm_payment_v;

CREATE OR REPLACE VIEW adp_payment_v AS 
         SELECT p.fin_payment_schedule_id AS adp_payment_v_id, i.em_adp_budget_id AS adp_budget_id, p.fin_payment_schedule_id, p.ad_client_id, p.ad_org_id, p.created, p.createdby, p.updated, p.updatedby, p.c_invoice_id, p.c_order_id, i.dateinvoiced AS fechafactura, p.duedate, 
         p.fin_paymentmethod_id, p.c_currency_id, p.amount, p.paidamt, p.outstandingamt, p.isactive, ccu.iso_code::character varying(3) AS budgetcurrency, 
                CASE
                    WHEN p.c_currency_id::text = ccu.c_currency_id::text THEN 0::numeric
                    ELSE ( SELECT cc.multiplyrate
                       FROM c_conversion_rate cc
                      WHERE cc.c_currency_id::text = p.c_currency_id::text AND cc.c_currency_id_to::text = cp.c_currency_id::text AND CC.ad_client_id = p.ad_client_id
                      ORDER BY cc.validto DESC
                     LIMIT 1)
                END AS cambio, 
                CASE
                    WHEN p.c_currency_id::text = ccu.c_currency_id::text THEN NULL::timestamp without time zone
                    ELSE ( SELECT cc.validto
                       FROM c_conversion_rate cc
                      WHERE cc.c_currency_id::text = p.c_currency_id::text AND cc.c_currency_id_to::text = cp.c_currency_id::text AND CC.ad_client_id = p.ad_client_id
                      ORDER BY cc.validto DESC
                     LIMIT 1)
                END AS fechacambio, 
                CASE
                    WHEN p.c_currency_id::text = ccu.c_currency_id::text THEN p.amount
                    ELSE p.amount * (( SELECT cc.multiplyrate
                       FROM c_conversion_rate cc
                      WHERE cc.c_currency_id::text = p.c_currency_id::text AND cc.c_currency_id_to::text = cp.c_currency_id::text AND CC.ad_client_id = p.ad_client_id
                      ORDER BY cc.validto DESC
                     LIMIT 1))
                END AS amountcambio, 
                CASE
                    WHEN p.c_currency_id::text = ccu.c_currency_id::text THEN NULL::timestamp without time zone
                    ELSE ( SELECT cc.validto
                       FROM c_conversion_rate cc
                      WHERE cc.c_currency_id::text = p.c_currency_id::text AND CC.ad_client_id = p.ad_client_id AND cc.c_currency_id_to::text = cp.c_currency_id::text AND cc.validto <= (( SELECT fin_payment_detail_v.paymentdate
                               FROM fin_payment_detail_v
                              WHERE fin_payment_detail_v.fin_payment_sched_ord_v_id::text = p.fin_payment_schedule_id::text
                              ORDER BY fin_payment_detail_v.updated DESC
                             LIMIT 1))
                      ORDER BY cc.validto DESC
                     LIMIT 1)
                END AS fechacambiopago, 
                CASE
                    WHEN p.c_currency_id::text = ccu.c_currency_id::text THEN p.paidamt
                    ELSE p.paidamt * (( SELECT COALESCE(cc.multiplyrate, 0::numeric) AS "coalesce"
                       FROM c_conversion_rate cc
                      WHERE cc.c_currency_id::text = p.c_currency_id::text AND CC.ad_client_id = p.ad_client_id AND cc.c_currency_id_to::text = cp.c_currency_id::text AND cc.validto <= (( SELECT fin_payment_detail_v.paymentdate
                               FROM fin_payment_detail_v
                              WHERE fin_payment_detail_v.fin_payment_sched_ord_v_id::text = p.fin_payment_schedule_id::text
                              ORDER BY fin_payment_detail_v.updated DESC
                             LIMIT 1))
                      ORDER BY cc.validto DESC
                     LIMIT 1))
                END AS paidamtcambio, 
                CASE
                    WHEN p.c_currency_id::text = ccu.c_currency_id::text THEN 0::numeric
                    ELSE p.outstandingamt * (( SELECT cc.multiplyrate
                       FROM c_conversion_rate cc
                      WHERE cc.c_currency_id::text = p.c_currency_id::text AND cc.c_currency_id_to::text = cp.c_currency_id::text AND cc.validto <= i.dateinvoiced  AND CC.ad_client_id = p.ad_client_id
                      ORDER BY cc.validto DESC
                     LIMIT 1))
                END AS outstandingamtcambio, p.fin_payment_priority_id, p.update_payment_plan, p.origduedate, p.description, p.expecteddate
           FROM c_invoice i
      LEFT JOIN fin_payment_schedule p ON i.c_invoice_id::text = p.c_invoice_id::text
   LEFT JOIN adp_budget apm ON apm.adp_budget_id::text = i.em_adp_budget_id::text
   LEFT JOIN c_project cp ON cp.c_project_id::text = apm.c_project_id::text
   LEFT JOIN c_currency ccu ON ccu.c_currency_id::text = cp.c_currency_id::text
  WHERE i.em_adp_budget_id IS NOT NULL
UNION 
         SELECT p.fin_payment_schedule_id AS adp_payment_v_id, o.em_adp_budget_id AS adp_budget_id, p.fin_payment_schedule_id, p.ad_client_id, p.ad_org_id, p.created, p.createdby, p.updated, p.updatedby, p.c_invoice_id, p.c_order_id, o.dateordered AS fechafactura, p.duedate, p.fin_paymentmethod_id, p.c_currency_id, p.amount, p.paidamt, p.outstandingamt, p.isactive, ccu.iso_code::character varying(3) AS budgetcurrency, 
                CASE
                    WHEN p.c_currency_id::text = ccu.c_currency_id::text THEN 0::numeric
                    ELSE ( SELECT cc.multiplyrate
                       FROM c_conversion_rate cc
                      WHERE cc.c_currency_id::text = p.c_currency_id::text AND cc.c_currency_id_to::text = cp.c_currency_id::text AND CC.ad_client_id = p.ad_client_id
                      ORDER BY cc.validto DESC
                     LIMIT 1)
                END AS cambio, 
                CASE
                    WHEN p.c_currency_id::text = ccu.c_currency_id::text THEN NULL::timestamp without time zone
                    ELSE ( SELECT cc.validto
                       FROM c_conversion_rate cc
                      WHERE cc.c_currency_id::text = p.c_currency_id::text AND cc.c_currency_id_to::text = cp.c_currency_id::text AND CC.ad_client_id = p.ad_client_id
                      ORDER BY cc.validto DESC
                     LIMIT 1)
                END AS fechacambio, 
                CASE
                    WHEN p.c_currency_id::text = ccu.c_currency_id::text THEN p.amount
                    ELSE p.amount * (( SELECT cc.multiplyrate
                       FROM c_conversion_rate cc
                      WHERE cc.c_currency_id::text = p.c_currency_id::text AND cc.c_currency_id_to::text = cp.c_currency_id::text AND CC.ad_client_id = p.ad_client_id
                      ORDER BY cc.validto DESC
                     LIMIT 1))
                END AS amountcambio, 
                CASE
                    WHEN p.c_currency_id::text = ccu.c_currency_id::text THEN NULL::timestamp without time zone
                    ELSE ( SELECT cc.validto
                       FROM c_conversion_rate cc
                      WHERE cc.c_currency_id::text = p.c_currency_id::text AND CC.ad_client_id = p.ad_client_id AND cc.c_currency_id_to::text = cp.c_currency_id::text AND cc.validto <= (( SELECT fin_payment_detail_v.paymentdate
                               FROM fin_payment_detail_v
                              WHERE fin_payment_detail_v.fin_payment_sched_ord_v_id::text = p.fin_payment_schedule_id::text
                              ORDER BY fin_payment_detail_v.updated DESC
                             LIMIT 1))
                      ORDER BY cc.validto DESC
                     LIMIT 1)
                END AS fechacambiopago, 
                CASE
                    WHEN p.c_currency_id::text = ccu.c_currency_id::text THEN p.paidamt
                    ELSE p.paidamt * (( SELECT COALESCE(cc.multiplyrate, 0::numeric) AS "coalesce"
                       FROM c_conversion_rate cc
                      WHERE cc.c_currency_id::text = p.c_currency_id::text AND CC.ad_client_id = p.ad_client_id AND cc.c_currency_id_to::text = cp.c_currency_id::text AND cc.validto <= (( SELECT fin_payment_detail_v.paymentdate
                               FROM fin_payment_detail_v
                              WHERE fin_payment_detail_v.fin_payment_sched_ord_v_id::text = p.fin_payment_schedule_id::text
                              ORDER BY fin_payment_detail_v.updated DESC
                             LIMIT 1))
                      ORDER BY cc.validto DESC
                     LIMIT 1))
                END AS paidamtcambio, 
                CASE
                    WHEN p.c_currency_id::text = ccu.c_currency_id::text THEN 0::numeric
                    ELSE p.outstandingamt * (( SELECT cc.multiplyrate
                       FROM c_conversion_rate cc
                      WHERE cc.c_currency_id::text = p.c_currency_id::text AND CC.ad_client_id = p.ad_client_id AND cc.c_currency_id_to::text = cp.c_currency_id::text AND cc.validto <= o.dateordered
                      ORDER BY cc.validto DESC
                     LIMIT 1))
                END AS outstandingamtcambio, p.fin_payment_priority_id, p.update_payment_plan, p.origduedate, p.description, p.expecteddate
           FROM c_order o
      LEFT JOIN fin_payment_schedule p ON o.c_order_id::text = p.c_order_id::text
   LEFT JOIN adp_budget apm ON apm.adp_budget_id::text = o.em_adp_budget_id::text
   LEFT JOIN c_project cp ON cp.c_project_id::text = apm.c_project_id::text
   LEFT JOIN c_currency ccu ON ccu.c_currency_id::text = cp.c_currency_id::text
  WHERE o.em_adp_budget_id IS NOT NULL;

ALTER TABLE adp_payment_v
  OWNER TO postgres;