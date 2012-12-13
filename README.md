PDTiledView
===========

Accordion-style table view, with block-based delegation.

## Installation

CocoaPods soon, but you can drop `PDTiledView.h/.m` into your project for now.

## Usage

Very similar to `UITableView`, but uses `sections` and `tiles` instead of `sections` and `rows`. It also uses blocks instead of protocols for delegation.

### Examples

```objective-c
PDTiledView *tiledView = ...;

tiledView.numberOfSectionsBlock = ^NSInteger { return 4; };

tiledViewdView.numberOfTilesInSectionBlock = ^NSInteger (NSInteger section) { return 20; };
```

All `sections` and `tiles` are just `UIControl` subclasses, such as `UIButton` or a custom control of your making. (This may switch to UIView later, not sold on it yet).

```objective-c
tiledView.controlForSectionBlock = ^UIControl *(NSInteger section) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor whiteColor];
    return button;
};

tiledView.controlForTileAtIndexPathBlock = ^UIControl *(PDIndexPath indexPath) {
    UIButton *button = [UIButton buttonWithType:UIControlIButtonTypeCustom];
    return button;
};
```

As a result of block-based delegation, you should explicitly call `reloadData` the first time the view will be displayed.

```objective-c
[tiledView reloadData];
```

You can also programmatically select a section by calling `selectSection:animated:`.

```objective-c
[tiledView selectSection:0 animated:NO];
```

There are also optional blocks to further customize how you like. They match up with their `UITableViewDelegate/DataSource` counterparts:

* `heightForSectionControlBlock`
* `heightForTilesInSectionBlock`
* `didSelectSectionBlock`
* `didSelectTileAtIndexPathBlock`
* `willDisplaySectionBlock` 
* `willDisplayTileAtIndexPathBlock` (This is where you should apply styling that is `frame`-dependent, as its final dimensions will be set. Same with `willDisplaySectionBlock`)

## Discussion

The internal implementation does not use `UITableView`s, so while some things are cached, tiles are not loaded on-the-fly and cached as rows are in UITableView. This shouldn't be a big deal unless you are displaying 1,000s of tiles or tiles are extremely rendering intensive. Pull requests are more than welcome to help implement caching, or perhaps to use `UITableView`s internally.

This also means that `controlForSectionBlock` and `controlForTileAtIndexPathBlock` are not called multiple times, usually just once.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contributors

[Parker Wightman](https://github.com/pwightman) ([@parkerwightman](http://twitter.com/parkerwightman))
