select
    id as payment_id,
    orderid as order_id,
    paymentmethod as payment_method,
    status,

    -- convert to dollars, instead of cents
    amount / 100 as amount,
    created as created_date

from raw.stripe.payment