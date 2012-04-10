package t::Util::MakeMockApp;
use sane;
use Aqua::Util;
use Text::Xslate;

sub app {
    my $BIN = Aqua::Util->findbin;
    my $template = Text::Xslate->new(
        path      => [ Aqua::Util->catfile($BIN, "template") ],
        syntax    => 'Metakolon',
        cache_dir => '/tmp',
        module    => [
            'Text::MultiMarkdown' => ['markdown'],
            'JavaScript::Value::Escape' => ['js']
        ],
        verbose => 2,
    );

    return +{
        charset =>  'UTF-8',
        template => $template,
        encoding => 'utf8',
    };
}

1;

