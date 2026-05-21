with

-- Import CTEs
customers as (

    select * from {{ ref('stg_jaffle_shop__customers') }}

),

paid_orders as (

    select * from {{ ref('int_paid_orders') }}

),


-- Final CTE
final as (

    select
        paid_orders.order_id,
        paid_orders.customer_id,
        paid_orders.order_placed_at,
        paid_orders.order_status,
        paid_orders.total_amount_paid,
        paid_orders.payment_finalized_date,

        -- sales transaction sequence
        row_number() over (order by paid_orders.order_id) as transaction_seq,

        -- customer sales sequence
        row_number() over (partition by paid_orders.customer_id order by paid_orders.order_id) as customer_sales_seq,

        -- new vs return order
        case
            when (
                rank() over (
                    partition by customer_id
                    order by order_placed_at, order_id
                ) = 1
            ) then 'new'
            else 'return' 
        end as nvsr,

        -- customer lifetime value
        sum(paid_orders.total_amount_paid) over (
            partition by paid_orders.customer_id
            order by paid_orders.order_id
        ) as customer_lifetime_value,

        -- first day of sale
        min(paid_orders.order_placed_at) over (
            partition by paid_orders.customer_id
        ) as fdos
    from paid_orders

    left join customers using (customer_id)

)

select * from final


