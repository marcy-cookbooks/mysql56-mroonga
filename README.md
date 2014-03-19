mysql56-mroonga Cookbook
========================
This cookbook install Oracle MySQL5.6 and Mroonga.

This cookbook is made in reference to this URL.

https://github.com/kazeburo/build_mysql_mroonga_rpm/

Requirements
------------
* CentOS6 or Amazon Linux 2013.09
* Chef 11 or higher
* opscode yum cookbook version 3.0.0 or higher

Attributes
----------
``` ruby
default['mysql56-mroonga']['mysql_version']          = "5.6.16-1"
default['mysql56-mroonga']['mroonga_version']        = "4.00-2"
default['mysql56-mroonga']['root_password']          = "password"
default['mysql56-mroonga']['mroonga_default_parser'] = "TokenMecab"
```

#### mysql56-mroonga::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['mysql56-mroonga']['mysql_version']</tt></td>
    <td>String</td>
    <td>Version of MySQL5.6</td>
    <td><tt>5.6.16-1</tt></td>
  </tr>
  <tr>
    <td><tt>['mysql56-mroonga']['mroonga_version']</tt></td>
    <td>String</td>
    <td>Version of Mroonga</td>
    <td><tt>4.00-2</tt></td>
  </tr>
  <tr>
    <td><tt>['mysql56-mroonga']['root_password']</tt></td>
    <td>String</td>
    <td>Password of MySQL root user</td>
    <td><tt>4.00-2</tt></td>
  </tr>
  <tr>
    <td><tt>['mysql56-mroonga']['mroonga_default_parser']</tt></td>
    <td>String</td>
    <td>Default parser for full text search</td>
    <td><tt>TokenMecab</tt></td>
  </tr>
</table>

Usage
-----
#### mysql56-mroonga::default
e.g.
Just include `mysql56-mroonga` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[mysql56-mroonga]"
  ]
}
```
