extends Node

var _exit_mutex: Mutex
var _load_queue_mutex: Mutex
var _purge_queue_mutex: Mutex
var _cache_mutex: Mutex
var _load_semaphore: Semaphore
var _purge_semaphore: Semaphore
var _load_thread: Thread
var _purge_thread: Thread

var _exit_thread: bool
var _load_queue: Array # [String]
var _purge_queue: Array # [String]
var _cache: Dictionary # {String : Image}


func _ready():
	_exit_thread = false
	_load_queue = []
	_purge_queue = []
	_cache = {}
	_exit_mutex = Mutex.new()
	_load_queue_mutex = Mutex.new()
	_purge_queue_mutex = Mutex.new()
	_cache_mutex = Mutex.new()
	_load_semaphore = Semaphore.new()
	_purge_semaphore = Semaphore.new()
	_load_thread = Thread.new()
	_purge_thread = Thread.new()
	var err = _load_thread.start(self, "_load_thread_loop", null, Thread.PRIORITY_NORMAL)
	if err != OK:
		print("Error ", err, " starting _load_thread")
	err = _purge_thread.start(self, "_purge_thread_loop", null, Thread.PRIORITY_NORMAL)
	if err != OK:
		print("Error ", err, " starting _purge_thread")


# This function is executed on the main thread.
func load_image_async(path: String, priority: bool = false):
	assert(path)
	print("Queueing for loading ", path)
	
	# Return immediately if the path is already in _purge_queue_mutex.
	_purge_queue_mutex.lock()
	if _purge_queue.has(path):
		_purge_queue_mutex.unlock()
		return
	_purge_queue_mutex.unlock()
	
	# Returns immediately if the image is already pending or loaded.
	if _threadsafe_is_path_in_cache(path):
		return
	
	_load_queue_mutex.lock()
	if _load_queue.has(path):
		# Return immediately if the path is already in the queue.
		_load_queue_mutex.unlock()
		return
	else:
		# Queue the path.
		if priority:
			_load_queue.push_front(path)
		else:
			_load_queue.push_back(path)
	_load_queue_mutex.unlock()
	
	# Unlock _thread_loop().
	_load_semaphore.post()


# This function is executed on the main thread.
func purge_image_async(path: String):
	assert(path)
	print("Queueing for purging ", path)
	
	# Retire path de _load_queue s'il s'y trouve.
	_load_queue_mutex.lock()
	if _load_queue.has(path):
		_load_queue.erase(path)
	_load_queue_mutex.lock()

	# L'image est peut-être en train d'être chargée. Dans ce cas, _purge_queue_mutex est locked dans _load_thread_loop.
	_purge_queue_mutex.lock()
	if _purge_queue.has(path):
		# Return immediately if the path is already in the queue.
		_purge_queue_mutex.unlock()
		return
	else:
		# Queue the path.
		_purge_queue.push_back(path)
	_purge_queue_mutex.unlock()
	
	# Unlock _thread_loop().
	_purge_semaphore.post()


# This function is executed on the main thread.
func fetch_image(path: String) -> Image:
	return _threadsafe_get_image_from_cache(path)


func _load_thread_loop(_unused):
	print("_load_thread_loop running...")
	while true:
		_load_semaphore.wait() # Wait until posted.
		
		if _threadsafe_check_exit_condition():
			break
		
		# Bloque purge_image_async pendant le chargement de l'image, pour que purge_image_async puisse l'inscrire au déchargement juste après.
		_purge_queue_mutex.lock()
		
		var path: = _threadsafe_get_next_load_task()
		assert(path)
		
		_cache_mutex.lock()
		_cache[path] = null # Pending
		_cache_mutex.unlock()
		
		var img: = _threadsafe_load_image(path)
		assert(img)
		
		_cache_mutex.lock()
		_cache[path] = img # Loaded
		_cache_mutex.unlock()

		_purge_queue_mutex.unlock()
	
		print("Loaded ", path)


func _purge_thread_loop(_unused):
	print("_purge_thread_loop running...")
	while true:
		_purge_semaphore.wait() # Wait until posted.
		
		if _threadsafe_check_exit_condition():
			break
		
		var path: = _threadsafe_get_next_purge_task()
		assert(path)
		
		_threadsafe_cancel_loading(path)
		
		_cache_mutex.lock()
		if _cache.has(path):
			_cache.erase(path)
		_cache_mutex.unlock()
	
		print("Purged ", path)


func _threadsafe_check_exit_condition() -> bool:
	_exit_mutex.lock()
	var exit_thread: bool = _exit_thread
	_exit_mutex.unlock()
	return exit_thread


# This function is executed on the thread loop.
func _threadsafe_load_image(path: String) -> Image:
#	texture_rect.texture = load(path)
	var img = Image.new()
	var err = img.load(path)
	if err != OK:
		print("Error loading image ", path, " : ", err)
		return null
	return img


func _threadsafe_get_next_load_task() -> String:
	_load_queue_mutex.lock()
	var path: String = _load_queue.pop_front()
	_load_queue_mutex.unlock()
	return path


func _threadsafe_cancel_loading(path: String):
	_load_queue_mutex.lock()
	if _load_queue.has(path):
		_load_queue.erase(path)
	_load_queue_mutex.unlock()


func _threadsafe_get_next_purge_task() -> String:
	_purge_queue_mutex.lock()
	var path: String = _purge_queue.pop_front()
	_purge_queue_mutex.unlock()
	return path


func _threadsafe_is_path_in_cache(path: String) -> bool:
	_cache_mutex.lock()
	var cached: bool = _cache.has(path)
	_cache_mutex.unlock()
	return cached


func _threadsafe_get_image_from_cache(path: String) -> Image:
	_cache_mutex.lock()
	var cached: bool = _cache.has(path)
	if !cached:
		_cache_mutex.unlock()
		return null
	var img: Image = _cache[path]
	_cache_mutex.unlock()
	return img


func _exit_tree():
	_exit_mutex.lock()
	_exit_thread = true
	_exit_mutex.unlock()
	_load_semaphore.post()
	_purge_semaphore.post()
	_load_thread.wait_to_finish()
	_purge_thread.wait_to_finish()
	_load_thread = null
	_purge_thread = null
