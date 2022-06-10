DROP TABLE IF EXISTS seancwiek.leh_pat_reqs;

CREATE TABLE seancwiek.leh_pat_reqs AS SELECT DISTINCT
    *
FROM (
    SELECT
        pr.pr_hrid AS lpr_hrid,
        pr.pr_title AS lpr_title,
        pr.pr_author AS lpr_author,
        pr.pr_isbn AS lpr_isbn,
        pr.pr_patron_identifier AS lpr_patron_identifier,
        pr.pr_patron_email lpr_patron_email,
        pr.pr_date_created AS lpr_date_created,
        pr.pr_pub_date AS lpr_pub_date,
        lrr.lrr_filled AS lpr_filled,
        pr.pr_bib_record_id AS lpr_bib_record_id
    FROM
        reshare_rs.patron_request pr
    LEFT JOIN seancwiek.leh_req_result lrr ON pr.pr_id = lrr.lrr_req_id
WHERE
    pr.pr_is_requester = TRUE
    AND pr."__origin" = 'lehigh') AS coldevdata;

DROP TABLE IF EXISTS seancwiek.leh_mat_types;

CREATE TABLE seancwiek.leh_mat_types AS
SELECT
    "__origin" AS lmt_origin,
    id AS lmt_id,
    replace(json_extract_path(mt."jsonb", 'name')::varchar, '"', '') AS lmt_format_label
FROM
    reshare_inventory.material_type mt
WHERE
    "__origin" = 'lehigh';

DROP TABLE IF EXISTS seancwiek.leh_req_result;

CREATE TABLE seancwiek.leh_req_result AS
SELECT
    rs.rs_req_id AS lrr_req_id,
    sum(
        CASE WHEN (rs_from_status = 'REQ_SHIPPED'
            AND rs_to_status = 'REQ_CHECKED_IN')
            OR rs_to_status = 'REQ_FILLED_LOCALLY' THEN
            1
        ELSE
            0
        END) AS lrr_filled
FROM
    reshare_derived.req_stats rs
WHERE
    rs.rs_requester = 'lehigh'
GROUP BY
    rs.rs_req_id;

