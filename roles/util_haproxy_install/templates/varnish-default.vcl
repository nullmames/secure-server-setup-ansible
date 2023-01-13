# Marker to tell the VCL compiler that this VCL has been written with the
# 4.0 or 4.1 syntax.
vcl 4.1;

# Pointing to haproxy
backend default {
    .host = "127.0.0.1";
    .port = "81";
}

backend grpc {
    .host = "127.0.0.1";
    .port = "82";
}

sub vcl_recv {
    # Happens before we check if we have this in cache already.
    #
    # Typically you clean up the request here, removing cookies you don't need,
    # rewriting the request, etc.

    if ( req.http.upgrade ~ "(?i)websocket" ) {
        return(pipe);
    }

    if ( req.http.host == "grpc.stargaze-apis.com" ) {
        set req.backend_hint = grpc;
        return(pass);
    }

    if (! req.url ~ "/ipfs") {
        return(pass);
    }

    return(hash);
}

sub vcl_pipe {
    # Added to handle websocket requests
    #
    # https://varnish-cache.org/docs/7.2/users-guide/vcl-example-websockets.html?highlight=websocket

    if ( req.http.upgrade ) {
        set bereq.http.upgrade = req.http.upgrade;
        set bereq.http.connection = req.http.connection;
    }
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.

    if ( bereq.url ~ "/ipfs" ) {
        set beresp.ttl = 1w;
        set beresp.grace = 24h;
    }
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.

}
