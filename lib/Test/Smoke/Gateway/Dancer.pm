package Test::Smoke::Gateway::Dancer;
use v5.10;
no if $] >= 5.018, warnings => 'experimental::smartmatch';

use Dancer ':syntax';

use Dancer::Plugin::DBIC;
use Encode qw/ encode decode encode_utf8 decode_utf8 /;
use Test::Smoke::Gateway;
use Try::Tiny;

no if $] >= 5.018, warnings => 'experimental::smartmatch';

my $gw = Test::Smoke::Gateway->new(schema => schema('default'));

post '/report' => sub {
    try {
        my $json = encode('utf-8', params->{json});
        my $data = from_json($json);
        my $report = $gw->post_report($data);
        debug("Report was posted, returning id = ", $report->id);
        return to_json({id => $report->id});
    }
    catch {
        when (/duplicate key/) {
            debug("Report is a duplicate: $_");
            return to_json(
                {
                    error    => 'Report already posted.',
                    db_error => "$_",
                }
            );
        }
        default {
            debug("Report could not be stored in the database: $_");
            return to_json(
                {
                    error    => 'Unexpected error.',
                    db_error => "$_"
                }
            );
        }
    };
};

get '/report/:id' => sub {
    my $report = $gw->get_report(params->{'id'});

    header 'content-type' => 'text/html; charset=utf-8';
    template 'report' => {
        report      => $report,
        title       => ($report ? $report->title : 'Error, report not found'),
        version     => $Test::Smoke::Gateway::VERSION,
        thisyear    => 1900 + (localtime)[5],
        decode_utf8 => sub { return decode_utf8( $_[0] ) },
    };
};

get '/logfile/:id' => sub {
    my $report = $gw->get_report(params->{'id'});

    header 'content-type' => 'text/html';
    template 'logfile' => {
        report   => $report,
        title    => ($report ? $report->title : 'Error, report not found'),
        version  => $Test::Smoke::Gateway::VERSION,
        thisyear => 1900 + (localtime)[5],
    };
};

get '/outfile/:id' => sub {
    my $report = $gw->get_report(params->{'id'});

    header 'content-type' => 'text/html';
    template 'outfile' => {
        report   => $report,
        title    => ($report ? $report->title : 'Error: report not found'),
        version  => $Test::Smoke::Gateway::VERSION,
        thisyear => 1900 + (localtime)[5],
    };
};

post '/search' => sub {
    header 'content-type' => 'text/html';
    template 'search' => {
        search   => $gw->search({params}),
        title    => 'Test::Smoke Database Search',
        version  => $Test::Smoke::Gateway::VERSION,
        thisyear => 1900 + (localtime)[5],
    };
};

get '/search' => sub {
    header 'content-type' => 'text/html';
    template 'search' => {
        search   => $gw->search({params}),
        title    => 'Test::Smoke Database Search',
        version  => $Test::Smoke::Gateway::VERSION,
        thisyear => 1900 + (localtime)[5],
    };
};

get '/latest-only' => sub {
    header 'content-type' => 'text/html';
    template 'latest' => {
        search   => $gw->latest_only(),
        title    => 'CoreSmoke Database Latest Plevel per host',
        version  => $Test::Smoke::Gateway::VERSION,
        thisyear => 1900 + (localtime)[5],
    };
};

get '/test' => sub {
    header 'content-type' => 'text/html';
    template 'test' => {
        title    => 'Test::Smoke Database TEST Page',
        version  => $Test::Smoke::Gateway::VERSION,
        thisyear => 1900 + (localtime)[5],
    };
};

get '/api/latest' => sub {
    my $latest_only = $gw->latest_only();
    my $latest = [
        map {
            my $flat = { $_->get_inflated_columns() };
            $flat->{smoke_date} = $_->smoke_date->rfc3339;
            $flat
        } @{ $latest_only->{reports} }
    ];
    my $response = {
        reports       => $latest,
        report_count  => scalar(@$latest),
        latest_plevel => $latest_only->{latest_plevel},
        rpp           => scalar(@$latest),
        page          => 1,
    };
    return to_json($response);
};

get '/api/reports_from_date/:epoch' => sub {
    return to_json($gw->api_get_reports_from_date(params->{epoch}));
};

get '/api/reports_from_id/:id' => sub {
    my @args = (params->{id});
    push @args, params->{limit} // 100;
    return to_json($gw->api_get_reports_from_id(@args));
};

get '/api/report_data/:id' => sub {
    return to_json($gw->api_get_report_data(params->{id}));
};

get '/api/full_report_data/:id' => sub {
    my $full_report_data = $gw->api_get_full_report_data(params->{id});

    return to_json($full_report_data);
};

get '/api/:file_type/:id' => sub {
    my $report = $gw->api_get_report_data(params->{id});
    my $file = params->{file_type} eq 'logfile'
        ? $report->{log_file}
        : $report->{out_file};
    return to_json( {file => $file} );
};

get '/api/matrix' => sub {
    return to_json($gw->failures_matrix());
};

get '/api/submatrix' => sub {
    my ($test, $pversion) = (params->{test}, params->{pversion});

    debug("API->submatrix for test '$test' (@{[$pversion ? $pversion : '']}) ", {params()});
    forward '/api/matrix' if !$test;

    my $reports = $gw->failures_submatrix(
        test => $test,
        ($pversion ? (pversion => $pversion) : ()),
    );
    return to_json({
        reports => $reports,
        test    => $test,
        ($pversion ? (pversion => $pversion) : ()),
    });
};

get '/api/searchparameters' => sub {
    return to_json($gw->api_get_search_parameters);
};

post '/api/searchresults' => sub {
    my $report_info = $gw->api_get_search_results({params});
    my $reports = [
        map {
            my $flat = { $_->get_inflated_columns() };
            $flat->{smoke_date} = $_->smoke_date->rfc3339;
            $flat
        } @{ $report_info->{reports} }
    ];
    my $response = {
        reports       => $reports,
        report_count  => $report_info->{report_count},
        latest_plevel => undef,
        rpp           => $report_info->{rpp},
        page          => $report_info->{page} // 1,
    };
    return to_json($response);
};

get '/api/version' => sub {
    my $schema_class = ref($gw->schema);
    return to_json(
        {
            version        => $gw->VERSION,
            schema_version => do { no strict 'refs'; ${$schema_class . '::SCHEMAVERSION'} },
            db_version     => $gw->db_version,
        }
    );
};

get '/matrix' => sub {
    my $matrix = $gw->failures_matrix();

    header('content-type' => 'text/html');
    template(
        matrix => {
            matrix   => $matrix,
            version  => $Test::Smoke::Gateway::VERSION,
            thisyear => 1900 + (localtime)[5],
        }
    );
};

get '/submatrix' => sub {
    my ($test, $pversion) = (params->{test}, params->{pversion});

    forward '/matrix' if !$test;

    my $reports = $gw->failures_submatrix(
        test => $test,
        ($pversion ? (pversion => $pversion) : ()),
    );

    header('content-type' => 'text/html');
    template(
        submatrix => {
            reports    => $reports,
            test       => $test,
            web_source => config->{web_source},
            version    => $Test::Smoke::Gateway::VERSION,
            thisyear   => 1900 + (localtime)[5],
        }
    );
};

get '/' => sub {
    forward '/latest-only';
};

# Deal with CORS for /api stuff
hook(before => sub {
    debug("before-hook [path]: ", my $path = request->path_info);
    return unless $path =~ qr{^ /api/.+ }x;
    debug("before-hook [method] ", my $http_method = uc(request->method));
    debug("before-hook [Origin] ", my $origin = request->header('Origin'));
    return unless $origin;

    my $method = request->header('Access-Control-Request-Method') // $http_method;
    status($http_method eq 'OPTIONS' ? 204 : 200);
    header(
        'Access-Control-Allow-Headers',
        request->header('Access-Control-Request-Headers')
    ) if request->header('Access-Control-Request-Headers');

    header('Access-Control-Allow-Methods' => $method);
    header('Access-Control-Allow-Origin' => $origin);
    content_type('text/plain');
    debug("Allow request: $method => $origin");
    return 1;
});

any qr{/api/.+} => sub { return };
1;
