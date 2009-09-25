use strict;
use warnings;
use ExtUtils::MakeMaker;

my %conf = (
    NAME          => 'Geo::Distance::XS',
    AUTHOR        => 'gray <gray@cpan.org>',
    LICENSE       => 'perl',
    VERSION_FROM  => 'lib/Geo/Distance/XS.pm',
    ABSTRACT_FROM => 'lib/Geo/Distance/XS.pm',
    LIBS          => ['-lm'],
    PREREQ_PM     => {
        'Geo::Distance' => 0,
        'Test::More'    => 0,
    },
    META_MERGE    => {
        resources => {
            repository => 'http://github.com/gray/geo-distance-xs',
        }
    },
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'Geo-Distance-XS-*' },
);

unless (eval { ExtUtils::MakeMaker->VERSION(6.46) }) {
    delete $conf{META_MERGE};
}

WriteMakefile(%conf);


sub MY::postamble {
    return <<"    MAKE_FRAG";
authortest:
\t\$(MAKE) -e \$(TEST_TYPE) TEST_FILES="xt/*.t"
    MAKE_FRAG
}

sub MY::dist_test {
    my $self = shift;
    return $self->MM::dist_test . <<"    MAKE_FRAG";
\tcd \$(DISTVNAME) && \$(MAKE) authortest \$(PASTHRU)
    MAKE_FRAG
}
