"""Generate the synthetic PDF fixtures for the reader comparison (WB-05, T-02.3).

Usage: python3 -I make_pdfs.py <small dir> <large dir> [<manifest path>]

Writes, deterministically from SEED (the same bytes on every run):
  <small dir>/fx_pdf_01.pdf  FX-PDF-01: 4 portrait pages of text, well under 1 MB
  <small dir>/fx_pdf_10.pdf  FX-PDF-10: the first half of FX-PDF-01 only (truncated)
  <small dir>/fx_pdf_11.pdf  FX-PDF-11: FX-PDF-01 with every cross-reference offset wrong
  <large dir>/fx_pdf_05.pdf  FX-PDF-05: 120 pages of noise images, between 140,000,000
                             and 149,500,000 bytes, below the limit under both readings
                             of "MB" (OQ-30). Never committed to Git.
and, if a manifest path is given, the FX-PDF-05 entry of large_files_manifest.json.

Python standard library only. Synthetic content only: no MFW sample PDF and no
third-party text. Noise images are a pessimistic proxy for file size, not for
the look or rendering cost of MFW's real pages.
"""

import hashlib
import json
import random
import sys
import zlib
from pathlib import Path

SEED = 20261031
NEAR_LIMIT_MIN = 140_000_000
NEAR_LIMIT_MAX = 149_500_000
LARGE_PAGES = 120
# 560 x 717 RGB noise is 1,204,560 bytes a page, about 144.6 MB in all.
IMAGE_WIDTH = 560
IMAGE_HEIGHT = 717
A4 = (595, 842)

SENTENCES = (
    "This is a synthetic test page for the reader comparison.",
    "The text is generated and belongs to no publication.",
    "Each page states its own number so a test can find it.",
    "Lines are spaced evenly to give the renderer plain text to draw.",
)


def pdf_string(text):
    """Escapes text for a PDF literal string (ASCII only)."""
    return "(" + text.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)") + ")"


def build_pdf(objects):
    """Serialises numbered objects (1-based bodies) into a complete PDF.

    The catalogue must be object 1. No dates or file identifiers are written,
    so the output depends only on the objects.
    """
    out = bytearray(b"%PDF-1.7\n%\xe2\xe3\xcf\xd3\n")
    offsets = []
    for number, body in enumerate(objects, start=1):
        offsets.append(len(out))
        out += f"{number} 0 obj\n".encode("ascii")
        out += body
        out += b"\nendobj\n"
    xref_at = len(out)
    out += f"xref\n0 {len(objects) + 1}\n".encode("ascii")
    out += b"0000000000 65535 f \n"
    for offset in offsets:
        out += f"{offset:010d} 00000 n \n".encode("ascii")
    out += f"trailer\n<< /Size {len(objects) + 1} /Root 1 0 R >>\n".encode("ascii")
    out += f"startxref\n{xref_at}\n%%EOF\n".encode("ascii")
    return bytes(out)


def stream(dictionary, data):
    return dictionary.encode("ascii") + f" /Length {len(data)} >>\nstream\n".encode("ascii") + data + b"\nendstream"


def text_pdf(label, pages):
    """A text-only PDF of `pages` A4 portrait pages, using the standard Helvetica font."""
    # 1 catalogue, 2 pages tree, 3 font, then a page and its content per page.
    page_numbers = [4 + 2 * index for index in range(pages)]
    kids = " ".join(f"{number} 0 R" for number in page_numbers)
    objects = [
        b"<< /Type /Catalog /Pages 2 0 R >>",
        f"<< /Type /Pages /Kids [{kids}] /Count {pages} >>".encode("ascii"),
        b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
    ]
    for index in range(pages):
        lines = [f"{label} page {index + 1} of {pages}"]
        lines += [SENTENCES[(index + row) % len(SENTENCES)] for row in range(24)]
        content = "BT /F1 12 Tf 72 770 Td 16 TL\n"
        content += "\n".join(f"{pdf_string(line)} '" for line in lines)
        content += "\nET"
        content_number = page_numbers[index] + 1
        objects.append(
            f"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 {A4[0]} {A4[1]}] "
            f"/Resources << /Font << /F1 3 0 R >> >> /Contents {content_number} 0 R >>".encode("ascii")
        )
        objects.append(stream("<<", content.encode("ascii")))
    return build_pdf(objects)


def near_limit_pdf(seed):
    """FX-PDF-05: LARGE_PAGES pages, each a full-page noise image and its page number."""
    noise = random.Random(seed)
    # 1 catalogue, 2 pages tree, 3 font, then a page, its content and its image per page.
    page_numbers = [4 + 3 * index for index in range(LARGE_PAGES)]
    kids = " ".join(f"{number} 0 R" for number in page_numbers)
    objects = [
        b"<< /Type /Catalog /Pages 2 0 R >>",
        f"<< /Type /Pages /Kids [{kids}] /Count {LARGE_PAGES} >>".encode("ascii"),
        b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
    ]
    for index in range(LARGE_PAGES):
        content_number = page_numbers[index] + 1
        image_number = page_numbers[index] + 2
        objects.append(
            f"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 {A4[0]} {A4[1]}] "
            f"/Resources << /Font << /F1 3 0 R >> /XObject << /Im1 {image_number} 0 R >> >> "
            f"/Contents {content_number} 0 R >>".encode("ascii")
        )
        content = (
            f"q {A4[0]} 0 0 {A4[1]} 0 0 cm /Im1 Do Q\n"
            f"BT /F1 24 Tf 72 72 Td {pdf_string(f'FX-PDF-05 page {index + 1} of {LARGE_PAGES}')} Tj ET"
        )
        objects.append(stream("<<", content.encode("ascii")))
        # Noise does not compress; level 1 keeps generation quick.
        pixels = zlib.compress(noise.randbytes(IMAGE_WIDTH * IMAGE_HEIGHT * 3), 1)
        objects.append(
            stream(
                f"<< /Type /XObject /Subtype /Image /Width {IMAGE_WIDTH} /Height {IMAGE_HEIGHT} "
                "/ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /FlateDecode",
                pixels,
            )
        )
    return build_pdf(objects)


def corrupt_xref(pdf):
    """FX-PDF-11: the same file with every in-use cross-reference offset pointing nowhere."""
    head, separator, tail = pdf.partition(b"\nxref\n")
    lines = tail.split(b"\n")
    for row, line in enumerate(lines):
        if line.endswith(b" 00000 n "):
            lines[row] = b"9999999999 00000 n "
    return head + separator + b"\n".join(lines)


def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    print(f"{path.name}: {len(data):,} bytes, sha256 {hashlib.sha256(data).hexdigest()}")
    return data


def main(argv):
    if len(argv) not in (3, 4):
        print(__doc__.splitlines()[2], file=sys.stderr)
        return 2
    small_dir, large_dir = Path(argv[1]), Path(argv[2])
    fx01 = write(small_dir / "fx_pdf_01.pdf", text_pdf("FX-PDF-01", 4))
    write(small_dir / "fx_pdf_10.pdf", fx01[: len(fx01) // 2])
    write(small_dir / "fx_pdf_11.pdf", corrupt_xref(fx01))
    fx05 = write(large_dir / "fx_pdf_05.pdf", near_limit_pdf(SEED))
    if not NEAR_LIMIT_MIN <= len(fx05) <= NEAR_LIMIT_MAX:
        print(f"FX-PDF-05 is {len(fx05):,} bytes, outside the near-limit range", file=sys.stderr)
        return 1
    if len(argv) == 4:
        manifest = Path(argv[3])
        manifest.parent.mkdir(parents=True, exist_ok=True)
        entry = {
            "id": "FX-PDF-05",
            "file": "fx_pdf_05.pdf",
            "bytes": len(fx05),
            "sha256": hashlib.sha256(fx05).hexdigest(),
            "pages": LARGE_PAGES,
            "generator": "tools/fixtures/make_pdfs.py",
            "seed": SEED,
            "stored": "outside Git (loop folder out/)",
        }
        manifest.write_text(json.dumps({"files": [entry]}, indent=2) + "\n", encoding="ascii")
        print(f"manifest: {manifest}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
