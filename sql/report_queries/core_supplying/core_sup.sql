SELECT
    *
FROM (
    SELECT
        ss_supplier AS supplier,
        count(DISTINCT ss_req_id) AS reqs,
        sum(
            CASE WHEN ss_to_status = 'RES_UNFILLED' THEN
                1
            ELSE
                0
            END) AS unfilled,
        sum(
            CASE WHEN ss_to_status = 'RES_AWAIT_SHIP' THEN
                1
            ELSE
                0
            END) AS filled,
        sum(
            CASE WHEN ss_to_status = 'RES_ITEM_SHIPPED'
                AND ss_from_status = 'RES_AWAIT_SHIP' THEN
                1
            ELSE
                0
            END) AS shipped,
        sum(
            CASE WHEN ss_to_status = 'RES_CANCELLED' THEN
                1
            ELSE
                0
            END) AS cancels,
        round(cast(sum(
                    CASE WHEN ss_to_status = 'RES_AWAIT_SHIP' THEN
                        1
                    ELSE
                        0
                    END) AS decimal) / count(DISTINCT ss_req_id), 2) AS filled_ratio,
        round(cast(sum(
                    CASE WHEN ss_to_status = 'RES_ITEM_SHIPPED'
                        AND ss_from_status = 'RES_AWAIT_SHIP' THEN
                        1
                    ELSE
                        0
                    END) AS decimal) / count(DISTINCT ss_req_id), 2) AS supplied_ratio
    FROM
        reshare_derived.sup_stats
    GROUP BY
        supplier
    UNION
    SELECT
        'consortium' AS supplier,
        count(DISTINCT ss_req_id) AS reqs,
        sum(
            CASE WHEN ss_to_status = 'RES_UNFILLED' THEN
                1
            ELSE
                0
            END) AS unfilled,
        sum(
            CASE WHEN ss_to_status = 'RES_AWAIT_SHIP' THEN
                1
            ELSE
                0
            END) AS filled,
        sum(
            CASE WHEN ss_to_status = 'RES_ITEM_SHIPPED'
                AND ss_from_status = 'RES_AWAIT_SHIP' THEN
                1
            ELSE
                0
            END) AS shipped,
        sum(
            CASE WHEN ss_to_status = 'RES_CANCELLED' THEN
                1
            ELSE
                0
            END) AS cancels,
        round(cast(sum(
                    CASE WHEN ss_to_status = 'RES_AWAIT_SHIP' THEN
                        1
                    ELSE
                        0
                    END) AS decimal) / count(DISTINCT ss_req_id), 2) AS filled_ratio,
        round(cast(sum(
                    CASE WHEN ss_to_status = 'RES_ITEM_SHIPPED'
                        AND ss_from_status = 'RES_AWAIT_SHIP' THEN
                        1
                    ELSE
                        0
                    END) AS decimal) / count(DISTINCT ss_req_id), 2) AS supplied_ratio
    FROM
        reshare_derived.sup_stats
    GROUP BY
        supplier) AS core_sup
ORDER BY
    (
        CASE WHEN core_sup.supplier = 'consortium' THEN
            0
        ELSE
            1
        END),
    core_sup.supplier;

