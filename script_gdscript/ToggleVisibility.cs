using Godot;

public partial class ToggleVisibility : Node
{
	[Export]
	public NodePath TargetNodePath
	{
		get => _targetNodePath;
		set
		{
			_targetNodePath = value;
			UpdateTargetNode();
		}
	}

	[Export]
	public NodePath ButtonTogglePath
	{
		get => _buttonTogglePath;
		set
		{
			_buttonTogglePath = value;
			UpdateButtonNode();
		}
	}

	// Signal name as a constant instead of exported property
	private const string ToggleSignal = "pressed";

	private Node _targetNode;
	private Node _buttonToggle;
	private NodePath _targetNodePath;
	private NodePath _buttonTogglePath;
	private bool _isInitialized;

	public override void _Ready()
	{
		UpdateTargetNode();
		UpdateButtonNode();
		SetupSignalConnection();
	}

	private void UpdateTargetNode()
	{
		if (!IsInsideTree()) return;

		_targetNode = GetNodeOrNull(TargetNodePath);
		if (_targetNode == null)
		{
			GD.PushError($"Error: 'TargetNodePath' ({TargetNodePath}) does not point to a valid node.");
			return;
		}

		if (!_targetNode.HasMethod("set_visible"))
		{
			GD.PushError($"Error: Target node ({_targetNode.Name}) does not have a 'visible' property.");
			_targetNode = null;
		}
	}

	private void UpdateButtonNode()
	{
		if (!IsInsideTree()) return;

		_buttonToggle = GetNodeOrNull(ButtonTogglePath);
		if (_buttonToggle == null)
		{
			GD.PushError($"Error: 'ButtonTogglePath' ({ButtonTogglePath}) does not point to a valid node.");
			return;
		}

		if (string.IsNullOrEmpty(ToggleSignal))
		{
			GD.PushError("Error: 'ToggleSignal' is not specified.");
			_buttonToggle = null;
		}
	}

	private void SetupSignalConnection()
	{
		if (_isInitialized || _buttonToggle == null || _targetNode == null) return;

		if (!_buttonToggle.HasSignal(ToggleSignal))
		{
			GD.PushError($"Error: Toggle node ({_buttonToggle.Name}) does not have signal '{ToggleSignal}'.");
			return;
		}

		if (!_buttonToggle.IsConnected(ToggleSignal, new Callable(this, nameof(OnToggleActivated))))
		{
			var error = _buttonToggle.Connect(ToggleSignal, new Callable(this, nameof(OnToggleActivated)));
			if (error != Error.Ok)
			{
				GD.PushError($"Error: Could not connect signal '{ToggleSignal}' from node '{_buttonToggle.Name}'. Error code: {(int)error}");
				return;
			}
		}

		_isInitialized = true;
	}

	private void OnToggleActivated()
	{
		if (_targetNode == null || !_targetNode.HasMethod("set_visible")) return;
		_targetNode.Set("visible", !_targetNode.Get("visible").AsBool());
	}

	public override void _ExitTree()
	{
		if (_buttonToggle != null && _buttonToggle.HasSignal(ToggleSignal))
		{
			if (_buttonToggle.IsConnected(ToggleSignal, new Callable(this, nameof(OnToggleActivated))))
			{
				_buttonToggle.Disconnect(ToggleSignal, new Callable(this, nameof(OnToggleActivated)));
			}
		}
		_isInitialized = false;
	}

	public override void _Notification(int what)
	{
		if (what == NotificationPathRenamed)
		{
			UpdateTargetNode();
			UpdateButtonNode();
			SetupSignalConnection();
		}
	}
}
