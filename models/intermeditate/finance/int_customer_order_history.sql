with

paid_orders as (

    select * from {{ ref('int_paid_orders') }}

),

customer_order_history as (

    select
        order_id,
        customer_id,
        order_placed_at,
        order_status,
        total_amount_paid,
        payment_finalized_date,

        row_number() over (
            partition by customer_id
            order by order_id
        ) as customer_sales_seq,

        case
            when rank() over (
                partition by customer_id
                order by order_placed_at, order_id
            ) = 1 then 'new'
            else 'return'
        end as new_vs_returning,

        sum(total_amount_paid) over (
            partition by customer_id
            order by order_id
        ) as customer_lifetime_value,

        min(order_placed_at) over (
            partition by customer_id
        ) as first_order_date

    from paid_orders

)

select * from customer_order_history

