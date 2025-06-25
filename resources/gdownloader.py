from sys import argv
from os.path import exists
from sys import stdout

from requests import Session

CHUNK_SIZE = 32768
DOWNLOAD_URL = 'https://docs.google.com/uc?export=download'


# From https://stackoverflow.com/questions/1094841/reusable-library-to-get-human-readable-version-of-file-size
def _sizeof_fmt(num, suffix='B'):
    for unit in ['', 'Ki', 'Mi', 'Gi', 'Ti', 'Pi', 'Ei', 'Zi']:
        if abs(num) < 1024.0:
            return '{:.1f} {}{}'.format(num, unit, suffix)
        num /= 1024.0
    return '{:.1f} {}{}'.format(num, 'Yi', suffix)


def _save_response_content(response, destination, showsize, current_size):
    with open(destination, 'wb') as f:
        for chunk in response.iter_content(CHUNK_SIZE):
            if chunk:  # filter out keep-alive new chunks
                f.write(chunk)
                if showsize:
                    print('\r' + _sizeof_fmt(current_size[0]), end=' ')
                    stdout.flush()
                    current_size[0] += CHUNK_SIZE


def download_file_from_google_drive(file_id: str, dest_path: str, overwrite=False, showsize=False):
    """
    Downloads a shared file from Google Drive into a given folder.
    Optionally unzips it.

    Parameters
    ----------
    file_id: str
        the file identifier.
        You can obtain it from the sharable link.
    dest_path: str
        the destination where to save the downloaded file.
        Must be a path (for example: './downloaded_file.txt')
    overwrite: bool
        optional, if True forces re-download and overwrite.
    showsize: bool
        optional, if True print the current download size.
    Returns
    -------
    None
    """
    if not exists(dest_path) or overwrite:

        session = Session()

        print('Downloading {} into {}... '.format(file_id, dest_path), end='')
        stdout.flush()

        params = {'id': file_id, 'confirm': True}
        response = session.post(DOWNLOAD_URL, params=params, stream=True)

        if showsize:
            print()  # Skip to the next line

        current_download_size = [0]
        _save_response_content(response, dest_path, showsize, current_download_size)
        print('Done.')

if __name__ == '__main__':
    download_file_from_google_drive(argv[1], argv[2], True, True)