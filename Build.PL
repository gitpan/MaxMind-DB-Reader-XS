use strict;
use warnings;

use lib 'inc';

use Config::AutoConf;
use Module::Build;

my $mb = Module::Build->new(
    _mb_args(),
    c_source => 'c',
);

$mb->extra_compiler_flags(
    @{ $mb->extra_compiler_flags },
    qw(-std=c99 -fms-extensions -Wall -g)
);
$mb->extra_linker_flags( @{ $mb->extra_linker_flags }, '-lmaxminddb' );

_check_c_prereqs($mb);

$mb->create_build_script();

sub _mb_args {
    # This is a funky way of allowing this code to run stand-alone and as a
    # template to be processes by Dist::Zilla::Plugin::ModuleBuild::Custom
    my $data = do { local $/; <DATA> };

    if ( $data !~ /^\#/ ) {
        my $args = eval $data;
        return %{$args};
    }
    else {
        return (
            module_name          => 'MaxMind::DB::Reader::XS',
            dist_abstract        => 'Whatever',
            dist_version         => '42',
            license              => 'perl',
            recursive_test_files => 1,
        );
    }
}

sub _check_c_prereqs {
    my $mb = shift;

    my @include_dirs = map { my $dir = $_; $dir =~ s/^-I//; $dir }
        grep { /^-I/ } @{ $mb->extra_compiler_flags() || [] };
    my @lib_dirs = grep { /^-L/ } @{ $mb->extra_linker_flags() || [] };

    my $ac = Config::AutoConf->new(
        extra_include_dirs => \@include_dirs,
        extra_link_flags   => \@lib_dirs,
    );

    unless ( $ac->check_lib( 'maxminddb', 'MMDB_lookup_string' ) ) {
        warn <<'EOF';

  It looks like you either don't have libmaxminddb installed or you have an
  older version installed that doesn't define the MMDB_lookup_string
  symbol. Please upgrade your libmaxminddb installation.

EOF

        exit 1;
    }

    unless ( $ac->check_header('maxminddb_config.h') ) {
        warn <<'EOF';

  It looks like the version of libmaxminddb you installed did not provide a
  maxminddb_config.h header. Please upgrade your libmaxminddb installation.

EOF

        exit 1;
    }

    unless ( $ac->check_type('unsigned __int128')
        || $ac->check_type('unsigned int __attribute__ ((__mode__ (TI)))') ) {

        warn <<'EOF';

  It looks like your compiler doesn't support the "unsigned __int128" or
  "unsigned int __attribute__ ((__mode__ (TI)))" types. One of these types is
  necessary to compile the MaxMind::DB::Reader::XS module.

EOF

        exit 1;
    }

    if (
        $ac->compute_int(
            'MMDB_UINT128_IS_BYTE_ARRAY', undef,
            '#include <maxminddb_config.h>'
        )
        ) {

        warn <<'EOF';

  It looks like your installed libmaxminddb was compiled with a compiler that
  doesn't support the "unsigned __int128" type. Please recompile it with your
  current compiler, which does appear to support this type.

EOF
    }
}

__DATA__
 {
          'dist_abstract' => 'Fast XS implementation of MaxMind DB reader',
          'test_requires' => {
                               'Test::MaxMind::DB::Common::Util' => '0',
                               'Net::Works::Network' => '0',
                               'Test::Fatal' => '0',
                               'utf8' => '0',
                               'Test::More' => '0',
                               'Test::Number::Delta' => '0',
                               'autodie' => '0',
                               'Path::Class' => '0',
                               'lib' => '0'
                             },
          'script_files' => [],
          'recursive_test_files' => 1,
          'license' => 'artistic_2',
          'build_requires' => {
                                'Module::Build' => '0.28'
                              },
          'dist_name' => 'MaxMind-DB-Reader-XS',
          'dist_author' => [
                             'Boris Zentner <bzentner@maxmind.com>',
                             'Dave Rolsky <drolsky@maxmind.com>',
                             'Ran Eilam <reilam@maxmind.com>'
                           ],
          'module_name' => 'MaxMind::DB::Reader::XS',
          'requires' => {
                          'warnings' => '0',
                          'namespace::autoclean' => '0',
                          'XSLoader' => '0',
                          'MaxMind::DB::Reader::Role::HasMetadata' => '0',
                          'MaxMind::DB::Metadata' => '0',
                          'Moo' => '0',
                          'MaxMind::DB::Reader::Role::Reader' => '0',
                          'MaxMind::DB::Types' => '0',
                          'perl' => '5.010000',
                          'strict' => '0',
                          'Math::Int128' => '0',
                          'MaxMind::DB::Reader' => '0.060001'
                        },
          'recommends' => {},
          'configure_requires' => {
                                    'Module::Build' => '0.28'
                                  },
          'dist_version' => '0.070000'
        };

