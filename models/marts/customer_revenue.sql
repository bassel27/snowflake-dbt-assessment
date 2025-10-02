SELECT
    o.o_custkey AS c_custkey,
    c.c_name AS customer_name,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_revenue
FROM {{ source('tpch', 'orders') }} o
LEFT JOIN {{ source('tpch', 'lineitem') }} l
    ON o.o_orderkey = l.l_orderkey
LEFT JOIN {{ source('tpch', 'customer') }} c
    ON o.o_custkey = c.c_custkey
GROUP BY
    o.o_custkey,
    c.c_name