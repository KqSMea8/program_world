 select p.polno,
    p.meter_unit_code,
    case
    when count(a.created_date) = count(b.created_date) then
    'N'
    else
    'Y'
    end isCollect

    from
    act_cg_new_pol_init p
    left join (select *
    from ACT_CG_PROPHET_CFG
    where base_day_one_profit is null
    and press_day_one_profit is null
    and dayone_profit_stress_vfa is null) a

    on p.polno = a.polno
    and p.brno = a.brno
    left join ACT_CG_PROPHET_CFG b
    on p.polno = b.polno
    and p.brno = b.brno
    group by p.polno, p.meter_unit_code;