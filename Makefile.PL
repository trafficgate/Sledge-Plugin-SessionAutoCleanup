use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'Sledge::Plugin::SessionAutoCleanup',
    'VERSION_FROM' => 'lib/Sledge/Plugin/SessionAutoCleanup.pm', # finds $VERSION
    'PREREQ_PM' => {
	Test::More => 0.32,
    },
);
