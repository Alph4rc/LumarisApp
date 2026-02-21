import 'package:flutter/material.dart';

/// 优化的图片加载组件
class OptimizedImage extends StatelessWidget {
  /// 本地图片路径或网络图片URL
  final String imageUrl;
  
  /// 图片宽度
  final double? width;
  
  /// 图片高度
  final double? height;
  
  /// 图片缩放模式
  final BoxFit fit;
  
  /// 占位符组件
  final Widget? placeholder;
  
  /// 错误占位符组件
  final Widget? errorWidget;
  
  /// 是否使用缓存
  final bool useCache;
  
  /// 是否为本地图片
  final bool isAsset;

  /// 构造函数
  const OptimizedImage.assets(
    this.imageUrl,
    {
      super.key,
      this.width,
      this.height,
      this.fit = BoxFit.cover,
      this.placeholder,
      this.errorWidget,
      this.useCache = true,
    }) : isAsset = true;

  /// 网络图片构造函数
  const OptimizedImage.network(
    this.imageUrl,
    {
      super.key,
      this.width,
      this.height,
      this.fit = BoxFit.cover,
      this.placeholder,
      this.errorWidget,
      this.useCache = true,
    }) : isAsset = false;
  
  /// 主构造函数
  const OptimizedImage(
    this.imageUrl,
    {
      super.key,
      this.width,
      this.height,
      this.fit = BoxFit.cover,
      this.placeholder,
      this.errorWidget,
      this.useCache = true,
      required this.isAsset,
    });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Image(
        image: isAsset 
            ? AssetImage(imageUrl)
            : NetworkImage(imageUrl),
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            // 图片加载完成
            return child;
          }
          
          // 显示占位符
          return placeholder ?? _defaultPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          // 图片加载失败
          return errorWidget ?? _defaultErrorWidget();
        },
      ),
    );
  }

  /// 默认占位符
  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: width != null ? width! * 0.5 : 24,
          height: height != null ? height! * 0.5 : 24,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  /// 默认错误占位符
  Widget _defaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(
        Icons.error_outline,
        color: Colors.grey[400],
        size: width != null ? width! * 0.5 : 24,
      ),
    );
  }
}

/// 懒加载图片组件
class LazyLoadImage extends StatefulWidget {
  /// 图片URL或路径
  final String imageUrl;
  
  /// 图片宽度
  final double? width;
  
  /// 图片高度
  final double? height;
  
  /// 图片缩放模式
  final BoxFit fit;
  
  /// 是否为本地图片
  final bool isAsset;

  /// 构造函数
  const LazyLoadImage.assets(
    this.imageUrl,
    {
      super.key,
      this.width,
      this.height,
      this.fit = BoxFit.cover,
    }) : isAsset = true;

  /// 网络图片构造函数
  const LazyLoadImage.network(
    this.imageUrl,
    {
      super.key,
      this.width,
      this.height,
      this.fit = BoxFit.cover,
    }) : isAsset = false;

  @override
  State<LazyLoadImage> createState() => _LazyLoadImageState();
}

class _LazyLoadImageState extends State<LazyLoadImage> {
  /// 是否可见
  bool _isVisible = false;
  
  /// 可见性检测器
  final _visibilityDetectorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    
    // 使用 WidgetsBinding 延迟检测可见性
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
      
      // 监听滚动事件
      _setupScrollListener();
    });
  }

  @override
  void dispose() {
    // 移除滚动监听器
    _removeScrollListener();
    super.dispose();
  }

  /// 设置滚动监听器
  void _setupScrollListener() {
    final context = _visibilityDetectorKey.currentContext;
    if (context == null) return;
    
    final scrollableState = Scrollable.maybeOf(context);
    if (scrollableState != null) {
      scrollableState.position.addListener(_checkVisibility);
    }
  }

  /// 移除滚动监听器
  void _removeScrollListener() {
    final context = _visibilityDetectorKey.currentContext;
    if (context == null) return;
    
    final scrollableState = Scrollable.maybeOf(context);
    if (scrollableState != null) {
      scrollableState.position.removeListener(_checkVisibility);
    }
  }

  /// 检查可见性
  void _checkVisibility() {
    final context = _visibilityDetectorKey.currentContext;
    if (context == null) return;
    
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    // 使用Scrollable.of获取滚动位置
    final scrollableState = Scrollable.maybeOf(context);
    if (scrollableState != null) {
      final scrollPosition = scrollableState.position;
      final viewportDimension = scrollPosition.viewportDimension;
      final pixels = scrollPosition.pixels;
      
      // 检查是否在视口中
      final isVisible = position.dy < pixels + viewportDimension &&
                       position.dy + size.height > pixels - 200; // 提前200px加载
      
      if (isVisible != _isVisible) {
        setState(() {
          _isVisible = isVisible;
        });
      }
    } else {
      // 如果没有滚动，默认可见
      if (!_isVisible) {
        setState(() {
          _isVisible = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: _visibilityDetectorKey,
      width: widget.width,
      height: widget.height,
      child: _isVisible
          ? OptimizedImage(
              widget.imageUrl,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              isAsset: widget.isAsset,
            )
          : Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[200],
            ),
    );
  }
}