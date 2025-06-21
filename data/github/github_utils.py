import datetime

def _rate_limit_fields(r):
    rc = r.core
    reset = rc.reset.replace(tzinfo=datetime.timezone.utc).astimezone()
    return [ 'limit:', rc.limit, 'remaining:', rc.remaining, 'reset:', reset.strftime('%Y-%m-%d %H:%M:%S %Z')]

def _rate_limit_get(gh):
    r = gh.get_rate_limit()
    r_fields = _rate_limit_fields(r)
    return (r, r_fields)

def rate_limit_start(gh):
    return _rate_limit_get(gh)

def rate_limit_end(gh, start_data):
    (r_before, r_before_fields) = start_data
    (r_after, r_after_fields) = _rate_limit_get(gh)
    r_delta = r_before.core.remaining - r_after.core.remaining
    # FIXME: This doesn't handle scripts that cross more than 1 rate limit reset
    if r_delta < 0:
        r_delta += r_before.core.limit
    return (r_before_fields, r_after_fields, r_delta)

def rate_limit_report(end_data):
    (r_before_fields, r_after_fields, r_delta) = end_data
    print('Github API rate limiting: before:', *r_before_fields)
    print('Github API rate limiting: after:', *r_after_fields)
    print('Github API rate limiting: usage:', r_delta, '(from this script and any concurrent usage)')
