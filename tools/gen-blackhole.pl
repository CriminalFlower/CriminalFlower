#!/usr/bin/env perl
# Генерирует assets/blackhole.svg — анимированную чёрную дыру для шапки профиля.
# Запуск: perl tools/gen-blackhole.pl > assets/blackhole.svg
use strict;
use warnings;
use utf8;
binmode STDOUT, ':encoding(UTF-8)';

srand(42);
my ($W, $H) = (1000, 420);
my ($cx, $cy) = (500, 175);
my $TILT = 0.17;           # наклон диска (ry/rx)
my $HOLE = 58;             # радиус тени горизонта событий

sub f { sprintf '%.1f', shift }

# --- звёзды ------------------------------------------------------------------
my $stars = '';
for (1 .. 110) {
    my ($x, $y) = (rand($W), rand($H));
    next if (($x - $cx) ** 2 + (($y - $cy) * 1.4) ** 2) < 130 ** 2;
    my $r   = 0.4 + rand(1.3);
    my $dur = 2 + rand(5);
    my $lo  = 0.15 + rand(0.3);
    my $col = ('#ffffff','#ffffff','#cfe3ff','#ffe7c4','#e3d4ff')[int rand 5];
    $stars .= sprintf qq{<circle cx="%s" cy="%s" r="%s" fill="%s"><animate attributeName="opacity" values="1;%s;1" dur="%ss" begin="-%ss" repeatCount="indefinite"/></circle>\n},
        f($x), f($y), f($r), $col, f($lo), f($dur), f(rand($dur));
}

# --- кольца аккреционного диска ---------------------------------------------
my $rings = '';
my @R = ([92, 7, 0.95, 3.2], [112, 6, 0.9, 4.0], [135, 5, 0.8, 5.2], [160, 4.5, 0.7, 6.5],
         [188, 4, 0.55, 8.0], [218, 3, 0.4, 10], [250, 2.2, 0.28, 13], [285, 1.5, 0.18, 16]);
for my $ring (@R) {
    my ($rx, $sw, $op, $dur) = @$ring;
    my $ry = $rx * $TILT;
    my $dash = join ' ', map { int(50 + rand 140) . ' ' . int(4 + rand 18) } 1 .. 6;
    $rings .= sprintf qq{<ellipse cx="$cx" cy="$cy" rx="%s" ry="%s" pathLength="1000" fill="none" stroke="url(#diskGrad)" stroke-width="%s" stroke-opacity="%s" stroke-dasharray="$dash" stroke-linecap="round"><animate attributeName="stroke-dashoffset" from="0" to="-1000" dur="%ss" repeatCount="indefinite"/></ellipse>\n},
        f($rx), f($ry), $sw, $op, $dur;
    $rings .= sprintf qq{<ellipse cx="$cx" cy="$cy" rx="%s" ry="%s" fill="none" stroke="url(#diskGrad)" stroke-width="%s" stroke-opacity="%s"/>\n},
        f($rx), f($ry), f($sw * 2.2), f($op * 0.25);
}

# --- частицы, падающие по спирали -------------------------------------------
my $particles = '';
for my $i (0 .. 9) {
    my $phase = rand(6.283);
    my @pts;
    for my $k (0 .. 120) {
        my $t  = $k / 120;
        my $r  = 300 - (300 - $HOLE + 4) * ($t ** 1.6);
        my $th = $phase + $t * 4.2 * 3.14159;
        push @pts, f($cx + $r * cos $th) . ',' . f($cy + $r * $TILT * sin $th);
    }
    my $path = 'M' . join(' L', @pts);
    my $dur  = 5 + rand(4);
    my $beg  = rand($dur);
    my $col  = ('#fff4d6','#ffc46b','#ff8a3d','#b8a4ff')[int rand 4];
    $particles .= sprintf qq{<circle r="2.2" fill="%s" filter="url(#soft)"><animateMotion dur="%ss" begin="-%ss" repeatCount="indefinite" path="%s"/><animate attributeName="opacity" values="0;1;1;0" keyTimes="0;0.1;0.85;1" dur="%ss" begin="-%ss" repeatCount="indefinite"/><animate attributeName="r" values="2.6;1.6;0.6" dur="%ss" begin="-%ss" repeatCount="indefinite"/></circle>\n},
        $col, f($dur), f($beg), $path, f($dur), f($beg), f($dur), f($beg);
}

print <<"SVG";
<svg xmlns="http://www.w3.org/2000/svg" width="$W" height="$H" viewBox="0 0 $W $H" role="img" aria-label="CriminalFlower — чёрная дыра">
<title>CriminalFlower</title>
<defs>
  <radialGradient id="space" cx="50%" cy="42%" r="75%">
    <stop offset="0" stop-color="#1a0f2e"/>
    <stop offset="0.45" stop-color="#0a0714"/>
    <stop offset="1" stop-color="#030208"/>
  </radialGradient>
  <radialGradient id="nebulaA" cx="0.5" cy="0.5" r="0.5">
    <stop offset="0" stop-color="#6b3cff" stop-opacity="0.35"/>
    <stop offset="1" stop-color="#6b3cff" stop-opacity="0"/>
  </radialGradient>
  <radialGradient id="nebulaB" cx="0.5" cy="0.5" r="0.5">
    <stop offset="0" stop-color="#ff5e8a" stop-opacity="0.22"/>
    <stop offset="1" stop-color="#ff5e8a" stop-opacity="0"/>
  </radialGradient>
  <linearGradient id="diskGrad" x1="0" x2="1" y1="0" y2="0">
    <stop offset="0" stop-color="#ff4d1a" stop-opacity="0"/>
    <stop offset="0.18" stop-color="#ffd9a0"/>
    <stop offset="0.32" stop-color="#fff6e6"/>
    <stop offset="0.55" stop-color="#ffb04a"/>
    <stop offset="0.8" stop-color="#ff5a1f"/>
    <stop offset="1" stop-color="#b3200a" stop-opacity="0"/>
  </linearGradient>
  <linearGradient id="lensGrad" x1="0" x2="0" y1="0" y2="1">
    <stop offset="0" stop-color="#fff3dc"/>
    <stop offset="0.5" stop-color="#ffa94d"/>
    <stop offset="1" stop-color="#ff5a1f" stop-opacity="0.2"/>
  </linearGradient>
  <radialGradient id="glow" cx="0.5" cy="0.5" r="0.5">
    <stop offset="0.35" stop-color="#ff9a3d" stop-opacity="0.55"/>
    <stop offset="0.6" stop-color="#ff5a1f" stop-opacity="0.18"/>
    <stop offset="1" stop-color="#ff5a1f" stop-opacity="0"/>
  </radialGradient>
  <linearGradient id="nameGrad" x1="0" x2="1" y1="0" y2="0">
    <stop offset="0" stop-color="#ffd9a0"/>
    <stop offset="0.5" stop-color="#ffffff"/>
    <stop offset="1" stop-color="#b8a4ff"/>
    <animate attributeName="x1" values="0;-1;0" dur="8s" repeatCount="indefinite"/>
    <animate attributeName="x2" values="1;2;1" dur="8s" repeatCount="indefinite"/>
  </linearGradient>
  <filter id="blur" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="6"/></filter>
  <filter id="soft" x="-200%" y="-200%" width="500%" height="500%"><feGaussianBlur stdDeviation="0.8"/></filter>
  <clipPath id="back"><rect x="0" y="0" width="$W" height="$cy"/></clipPath>
  <clipPath id="front"><rect x="0" y="$cy" width="$W" height="$H"/></clipPath>
  <g id="disk">
$rings  </g>
</defs>

<rect width="$W" height="$H" fill="url(#space)"/>
<ellipse cx="190" cy="120" rx="260" ry="140" fill="url(#nebulaA)">
  <animate attributeName="opacity" values="0.7;1;0.7" dur="9s" repeatCount="indefinite"/>
</ellipse>
<ellipse cx="830" cy="300" rx="280" ry="150" fill="url(#nebulaB)">
  <animate attributeName="opacity" values="1;0.6;1" dur="11s" repeatCount="indefinite"/>
</ellipse>
<g>
$stars</g>

<!-- свечение -->
<circle cx="$cx" cy="$cy" r="230" fill="url(#glow)">
  <animate attributeName="r" values="220;245;220" dur="6s" repeatCount="indefinite"/>
</circle>

<!-- задняя половина диска -->
<g clip-path="url(#back)">
  <use href="#disk" filter="url(#blur)" opacity="0.8"/>
  <use href="#disk"/>
</g>

<!-- линзированное изображение диска над и под тенью -->
<g>
  <circle cx="$cx" cy="$cy" r="@{[ $HOLE + 22 ]}" fill="none" stroke="url(#lensGrad)" stroke-width="16" opacity="0.35" filter="url(#blur)"/>
  <circle cx="$cx" cy="$cy" r="@{[ $HOLE + 14 ]}" fill="none" stroke="url(#lensGrad)" stroke-width="5" opacity="0.5"/>
  <circle cx="$cx" cy="$cy" r="@{[ $HOLE + 14 ]}" fill="none" stroke="url(#lensGrad)" stroke-width="7" pathLength="1000" stroke-dasharray="320 10 210 8 380 12 60 0" opacity="0.85">
    <animateTransform attributeName="transform" type="rotate" from="0 $cx $cy" to="360 $cx $cy" dur="7s" repeatCount="indefinite"/>
  </circle>
  <circle cx="$cx" cy="$cy" r="@{[ $HOLE + 6 ]}" fill="none" stroke="#fff4e0" stroke-width="2.5" opacity="0.95">
    <animate attributeName="opacity" values="0.95;0.6;0.95" dur="3s" repeatCount="indefinite"/>
  </circle>
</g>

<!-- горизонт событий -->
<circle cx="$cx" cy="$cy" r="$HOLE" fill="#000"/>

<!-- передняя половина диска поверх тени -->
<g clip-path="url(#front)">
  <use href="#disk" filter="url(#blur)" opacity="0.8"/>
  <use href="#disk"/>
</g>

<!-- падающая материя -->
<g>
$particles</g>

<!-- подпись -->
<g font-family="'Segoe UI', -apple-system, BlinkMacSystemFont, 'Helvetica Neue', Arial, sans-serif" text-anchor="middle">
  <text x="$cx" y="352" font-size="44" font-weight="800" letter-spacing="3" fill="url(#nameGrad)">CriminalFlower</text>
  <text x="$cx" y="388" font-size="17" fill="#c9bfe6" letter-spacing="1.5">Plugin &amp; Android Developer  ·  Telegram  ·  UI/UX  ·  Automation</text>
</g>
</svg>
SVG
