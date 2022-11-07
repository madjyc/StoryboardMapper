extends Resource
class_name GraphData

# Load/save data
export var version_major: int
export var version_minor: int
export var version_subminor: int

export var scroll_offset: Vector2
export var zoom: float
export var use_snap : bool
export var snap_distance: int

export var graph_bg_color: Color
export var img_node_bg_color: Color

export var img_nodes: Array # array of GraphNodeData
export var connections: Array # array of connections
export var com_nodes: Array # array of GraphNodeData
