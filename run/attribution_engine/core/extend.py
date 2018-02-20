#!/usr/bin/env python3

from functools import wraps
from flask import(
                    flash,
                    g,
                    redirect,
                    request,
                    url_for)


def authorize(function):
    @wraps(function)
    def authorizing(*args, **kwargs):
        if g.username is None:
            flash(u'Please log-in.', 'error')
            return redirect(url_for('core.authenticate', next=request.path))
        return function(*args, **kwargs)
    return authorizing