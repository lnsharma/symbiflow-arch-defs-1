import re

# =============================================================================

# A regex used for fixing pin names
RE_PIN_NAME = re.compile(r"^([A-Za-z0-9_]+)(?:\[([0-9]+)\])?$")

# =============================================================================


def get_pin_name(name):
    """
    Returns the pin name and its index in bus. If a pin is not a member of
    a bus then the index is None

    >>> get_pin_name("WIRE")
    ('WIRE', None)
    >>> get_pin_name("DATA[12]")
    ('DATA', 12)
    """

    match = re.match(r"(?P<name>.*)\[(?P<idx>[0-9]+)\]$", name)
    if match:
        return match.group("name"), int(match.group("idx"))
    else:
        return name, None


def fixup_pin_name(name):
    """
    Renames a pin to make its name suitable for VPR.

    >>> fixup_pin_name("A_WIRE")
    'A_WIRE'
    >>> fixup_pin_name("ADDRESS[17]")
    'ADDRESS_17'
    >>> fixup_pin_name("DATA[11]_X")
    Traceback (most recent call last):
        ...
    AssertionError: DATA[11]_X
    """

    match = RE_PIN_NAME.match(name)
    assert match is not None, name

    groups = match.groups()
    if groups[1] is None:
        return groups[0]
    else:
        return "{}_{}".format(*groups)


def add_index_suffix(name, index):
    """
    Adds the index suffix to the name. If the suffix is already present checks
    whether it matches the given index.

    >>> add_index_suffix("PIN_NAME", 15)
    'PIN_NAME[15]'
    >>> add_index_suffix("ADDRESS[31]", 31)
    'ADDRESS[31]'
    >>> add_index_suffix("DATA[9]", 10)
    Traceback (most recent call last):
        ...
    AssertionError: ('DATA[9]', 9, 10)
    """

    # Check for suffix
    match = re.match(r".*\[(?P<idx>[0-9]+)\]$", name)
    if match is not None:
        idx = int(match.group("idx"))
        assert idx == index, (name, idx, index,)
        return name

    # Append the index suffix
    return name + "[{}]".format(index)

# =============================================================================


def yield_muxes(switchbox):
    """
    Yields all muxes of a switchbox. Returns tuples with:
    (stage, switch, mux)
    """

    for stage in switchbox.stages.values():
        for switch in stage.switches.values():
            for mux in switch.muxes.values():
                yield stage, switch, mux


# =============================================================================


def get_quadrant_for_loc(loc, quadrants):
    """
    Assigns a quadrant to the given location. Returns None if no one matches.
    """

    for quadrant in quadrants.values():
        if loc.x >= quadrant.x0 and loc.x <= quadrant.x1:
            if loc.y >= quadrant.y0 and loc.y <= quadrant.y1:
                return quadrant

    return None


def get_loc_of_cell(cell_name, tile_grid):
    """
    Returns loc of a cell with the given name in the tilegrid.
    """

    # Look for a tile that has the cell
    for loc, tile in tile_grid.items():
        if tile is None:
            continue

        cell_names = [c.name for c in tile.cells]
        if cell_name in cell_names:
            return loc

    # Not found
    return None


def find_cell_in_tile(cell_name, tile):
    """
    Finds a cell instance with the given name inside the given tile.
    Returns the Cell object if found and None otherwise.
    """
    for cell in tile.cells:
        if cell.name == cell_name:
            return cell

    return None


# =============================================================================


def add_named_item(item_dict, item, item_name):
    """
    Adds a named item to the given dict if not already there. If it is there
    then returns the one from the dict.
    """

    if item_name not in item_dict:
        item_dict[item_name] = item

    return item_dict[item_name]


# =============================================================================


def natural_keys(text):
    """
    alist.sort(key=natural_keys) sorts in human order
    http://nedbatchelder.com/blog/200712/human_sorting.html
    (See Toothy's implementation in the comments)

    https://stackoverflow.com/questions/5967500/how-to-correctly-sort-a-string-with-a-number-inside
    """

    def atoi(text):
        return int(text) if text.isdigit() else text

    return [atoi(c) for c in re.split(r'(\d+)', text)]
