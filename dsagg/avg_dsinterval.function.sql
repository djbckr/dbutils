create or replace function avg_dsinterval
  ( input dsinterval_unconstrained )
  return dsinterval_unconstrained
  authid current_user
  parallel_enable
  aggregate using dsinterval_avg;
/

create or replace public synonym avg_dsinterval for avg_dsinterval;
grant execute on avg_dsinterval to public;
