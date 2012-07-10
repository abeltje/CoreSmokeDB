package Test::Smoke::Gateway::Dancer;
use v5.10;
use Dancer ':syntax';

use Exporter 'import';
our @EXPORT = qw/pass_gateway/;

my $gw;
sub pass_gateway { $gw = shift }

post '/report' => sub {
    try {
        my $data = from_json(params->{'json'});
        my $report = $gw->post_report($data);
        return to_json({id => $report->id});
    }
    catch {
        when (/duplicate key/) {
            return to_json(
                {
                    error    => 'Report already posted.',
                    db_error => "$_",
                }
            );
        }
        default {
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

    header 'content-type' => 'text/html';
    template 'report' => {
        report   => $report,
        title    => $report->title,
        version  => $Test::Smoke::Gateway::VERSION,
        thisyear => 1900 + (localtime)[5],
    };
};

get '/logfile/:id' => sub {
    my $report = $gw->get_report(params->{'id'});

    header 'content-type' => 'text/html';
    template 'logfile' => {
        report   => $report,
        title    => $report->title,
        version  => $Test::Smoke::Gateway::VERSION,
        thisyear => 1900 + (localtime)[5],
    };
};

get '/outfile/:id' => sub {
    my $report = $gw->get_report(params->{'id'});

    header 'content-type' => 'text/html';
    template 'outfile' => {
        report   => $report,
        title    => $report->title,
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

get '/api/reports_from_date/:epoch' => sub {
    return to_json($gw->api_get_reports_from_date(params->{epoch}));
};

get '/api/report_data/:id' => sub {
    return to_json($gw->api_get_report_data(params->{id}));
};

get '/' => sub {
    forward '/search';
};

1;
