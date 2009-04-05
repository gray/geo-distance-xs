use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
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
    (eval { ExtUtils::MakeMaker->VERSION(6.46) } ? (
        META_MERGE => {
            resources => {
                Repository => 'http://github.com/gray/geo-distance-xs',
            }
        }
    ) : () ),
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'Geo-Distance-XS-*' },
);
