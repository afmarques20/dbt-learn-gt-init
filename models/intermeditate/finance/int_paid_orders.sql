
with payment as (

    select * from {{ ref('stg_stripe__payments') }}
    where payment_status <> 'fail'

),

orders as (

    select * from {{ ref('stg_jaffle_shop__orders') }}

),


completed_payments as (

    select 
        order_id,
        max(payment_created_at) as payment_finalized_date,
        sum(amount) as total_amount_paid
    from payment
    group by 1

),

paid_orders as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_placed_at,
        orders.order_status,
        completed_payments.total_amount_paid,
        completed_payments.payment_finalized_date
    from orders

    left join completed_payments using (order_id)

)

select * from paid_orders

