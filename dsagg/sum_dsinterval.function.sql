create or replace function sum_dsinterval
  ( input dsinterval_unconstrained )
  return dsinterval_unconstrained
  authid current_user
  parallel_enable
  aggregate using dsinterval_sum;
/

create or replace public synonym sum_dsinterval for sum_dsinterval;
grant execute on sum_dsinterval to public;
