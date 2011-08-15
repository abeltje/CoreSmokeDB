package Test::Smoke::Gateway;
use Moose;

require Digest::MD5;
require JSON::PP;

has schema => (is => 'ro');

our $VERSION = 0.01;

=head1 NAME

Test::Smoke::Gateway - The basic gateway between smoker and MetaBase.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 post_report($data)

Handle http-post to /report/ to the database.

Returns the database object.

=cut

sub post_report {
    my ($self, $data) = @_;

    my $sconfig = $self->post_smoke_config(delete $data->{'_config'});

    my $report_data = {
        %{ delete $data->{'id'}    },
        %{ delete $data->{'node'}  },
        %{ delete $data->{'build'} },
        sconfig_id => $sconfig->id,
    };
    $report_data->{lc($_)} = delete $report_data->{$_} for keys %$report_data;

    return $self->schema->txn_do(
        sub {
            my $r = $self->schema->resultset('Report')->create($report_data);
            for my $config ( @{ $data->{'configs'} } ) {
                my $reports = delete $config->{'reports'};
                my $c = $r->create_related('configs', $config);
                for my $report ( @$reports ) {
                    my $s = $c->create_related('reports', $report);
                }
            }
            return $r;
        }
    );
};

=head2 get_report($id)

Fetches the report from the database.

Returns the database object.

=cut

sub get_report {
    my ($self, $id) = @_;

    return $self->schema->resultset('Report')->search({ 'id' => $id })->first;
}

=head2 post_smoke_config($data)

Checks to see if this smoke_config is already in the database. If not,
insert it.

Returns the database object.

=cut

sub post_smoke_config {
    my ($self, $sconfig) = @_;

    my $all_data = "";
    for my $key ( sort keys %$sconfig ) {
        $all_data .= $sconfig->{$key} || "";
    }
    my $md5 = Digest::MD5::md5_hex($all_data);

    my $sc_data = $self->schema->resultset('SmokeConfig')->find(
        $md5,
        { key => 'smoke_config_md5_key' }
    );

    if ( ! $sc_data ) {
        $sc_data = $self->schema->txn_do(
            sub {
                my $json = JSON::PP->new()->utf8(1)->encode($sconfig);
                return $self->schema->resultset('SmokeConfig')->create(
                    {
                        md5    => $md5,
                        config => $json,
                    }
                );
            }
        );
    }
    return $sc_data;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 STUFF

(c) MMXI - Abe Timmerman <abeltje@cpan.org>

=cut
