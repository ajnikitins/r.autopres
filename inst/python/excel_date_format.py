EXCEL_CODES = {
        'yyyy': '%Y',
        'yy': '%y',
        'dddd': '%A',
        'ddd': '%a',
        'dd': '%d',
        'd': '%-d',
        # Different from excel as there is no J-D in strftime
        'mmmmmm': '%b',
        'mmmm': '%B',
        'mmm': '%b',
        'hh': '%H',
        'h': '%-H',
        'ss': '%S',
        's': '%-S',
        # Possibly different from excel as there is no am/pm in strftime
        'am/pm': '%p',
        # Different from excel as there is no A/P or a/p in strftime
        'a/p': '%p',
}

EXCEL_MINUTE_CODES = {
    'mm': '%M',
    'm': '%-M',
}
EXCEL_MONTH_CODES = {
    'mm': '%m',
    'm': '%-m',
}

EXCEL_MISC_CHARS = [
    '$',
    '+',
    '(',
    ':',
    '^',
    '\'',
    '{',
    '<',
    '=',
    '-',
    '/',
    ')',
    '!',
    '&',
    '~',
    '}',
    '>',
    ' ',
]

EXCEL_ESCAPE_CHAR = '\\'
EXCEL_SECTION_DIVIDER = ';'

def convert_excel_date_fmt(excel_date):
    '''
    Created using documentation here:
    https://support.office.com/en-us/article/review-guidelines-for-customizing-a-number-format-c0a1d1fa-d3f4-4018-96b7-9c9354dd99f5

    '''
    # The python date string that is being built
    python_date = ''
    # The excel code currently being parsed
    excel_code = ''
    prev_code = ''
    # If the previous character was the escape character
    char_escaped = False
    # If we are in a quotation block (surrounded by "")
    quotation_block = False
    # Variables used for checking if a code should be a minute or a month
    checking_minute_or_month = False
    minute_or_month_buffer = ''

    for c in excel_date:
        ec = excel_code.lower()
        # The previous character was an escape, the next character should be added normally
        if char_escaped:
            if checking_minute_or_month:
                minute_or_month_buffer += c
            else:
                python_date += c
            char_escaped = False
            continue
        # Inside a quotation block
        if quotation_block:
            if c == '"':
                # Quotation block should now end
                quotation_block = False
            elif checking_minute_or_month:
                minute_or_month_buffer += c
            else:
                python_date += c
            continue
        # The start of a quotation block
        if c == '"':
            quotation_block = True
            continue
        if c == EXCEL_SECTION_DIVIDER:
            # We ignore excel sections for datetimes
            break

        is_escape_char = c == EXCEL_ESCAPE_CHAR
        # The am/pm and a/p code add some complications, need to make sure we are not that code
        is_misc_char = c in EXCEL_MISC_CHARS and (c != '/' or (ec != 'am' and ec != 'a'))
        # Code is finished, check if it is a proper code
        if (is_escape_char or is_misc_char) and ec:
            # Checking if the previous code should have been minute or month
            if checking_minute_or_month:
                if ec == 'ss' or ec == 's':
                    # It should be a minute!
                    minute_or_month_buffer = EXCEL_MINUTE_CODES[prev_code] + minute_or_month_buffer
                else:
                    # It should be a months!
                    minute_or_month_buffer = EXCEL_MONTH_CODES[prev_code] + minute_or_month_buffer
                python_date += minute_or_month_buffer
                checking_minute_or_month = False
                minute_or_month_buffer = ''

            if ec in EXCEL_CODES:
                python_date += EXCEL_CODES[ec]
            # Handle months/minutes differently
            elif ec in EXCEL_MINUTE_CODES:
                # If preceded by hours, we know this is referring to minutes
                if prev_code == 'h' or prev_code == 'hh':
                    python_date += EXCEL_MINUTE_CODES[ec]
                else:
                    # Have to check if the next code is ss or s
                    checking_minute_or_month = True
                    minute_or_month_buffer = ''
            else:
                # Have to abandon this attempt to convert because the code is not recognized
                return None
            prev_code = ec
            excel_code = ''
        if is_escape_char:
            char_escaped = True
        elif is_misc_char:
            # Add the misc char
            if checking_minute_or_month:
                minute_or_month_buffer += c
            else:
                python_date += c
        else:
            # Just add to the code
            excel_code += c

    # Complete, check if there is still a buffer
    if checking_minute_or_month:
        # We know it's a month because there were no more codes after
        minute_or_month_buffer = EXCEL_MONTH_CODES[prev_code] + minute_or_month_buffer
        python_date += minute_or_month_buffer
    if excel_code:
        ec = excel_code.lower()
        if ec in EXCEL_CODES:
            python_date += EXCEL_CODES[ec]
        elif ec in EXCEL_MINUTE_CODES:
            if prev_code == 'h' or prev_code == 'hh':
                python_date += EXCEL_MINUTE_CODES[ec]
            else:
                python_date += EXCEL_MONTH_CODES[ec]
        else:
            return None
    return python_date
