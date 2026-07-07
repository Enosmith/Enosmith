---
title: mall视频教程
date: 2024-03-04 22:02:58
tags:
---

# Lombok使用教程

#### val

使用val注解可以取代任意类型作为局部变量，这样我们就不用写复杂的ArrayList和Map.Entry之类很复杂的类型了，具体例子如下。

> 会自动识别和编译，貌似任何类型都可以，可以少些一点代码

```java
/**
 * @auther macrozheng
 * @description val注解使用示例
 * @date 2020/12/16
 * @github https://github.com/macrozheng
 */
public class ValExample {

    public static void example() {
        //val代替ArrayList<String>和String类型
        val example = new ArrayList<String>();
        example.add("Hello World!");
        val foo = example.get(0);
        System.out.println(foo.toLowerCase());
    }

    public static void example2() {
        //val代替Map.Entry<Integer,String>类型
        val map = new HashMap<Integer, String>();
        map.put(0, "zero");
        map.put(5, "five");
        for (val entry : map.entrySet()) {
            System.out.printf("%d: %s\n", entry.getKey(), entry.getValue());
        }
    }

    public static void main(String[] args) {
        example();
        example2();
    }
}
```

当我们使用了val注解后，Lombok会从局部变量的初始化表达式推断出具体类型，编译后会生成如下代码。

```java
public class ValExample {
    public ValExample() {
    }

    public static void example() {
        ArrayList<String> example = new ArrayList();
        example.add("Hello World!");
        String foo = (String)example.get(0);
        System.out.println(foo.toLowerCase());
    }

    public static void example2() {
        HashMap<Integer, String> map = new HashMap();
        map.put(0, "zero");
        map.put(5, "five");
        Iterator var1 = map.entrySet().iterator();

        while(var1.hasNext()) {
            Entry<Integer, String> entry = (Entry)var1.next();
            System.out.printf("%d: %s\n", entry.getKey(), entry.getValue());
        }

    }
}
```

#### @NonNull

在方法上使用@NonNull注解可以做非空判断，如果传入空值的话会直接抛出NullPointerException。

```java
/**
 * @auther macrozheng
 * @description @NonNull注解使用示例
 * @date 2020/12/16
 * @github https://github.com/macrozheng
 */
public class NonNullExample {
    private String name;
    public NonNullExample(@NonNull String name){
        this.name = name;
    }

    public static void main(String[] args) {
        new NonNullExample("test");
        //会抛出NullPointerException
        new NonNullExample(null);
    }
}
```

#### @Cleanup

当我们在Java中使用资源时，不可避免地需要在使用后关闭资源。使用@Cleanup注解可以自动关闭资源（这个牛逼）

```java
/**
 * @auther macrozheng
 * @description @Cleanup注解使用示例
 * @date 2020/12/16
 * @github https://github.com/macrozheng
 */
public class CleanupExample {
    public static void main(String[] args) throws IOException {
        String inStr = "Hello World!";
        //使用输入输出流自动关闭，无需编写try catch和调用close()方法
        @Cleanup ByteArrayInputStream in = new ByteArrayInputStream(inStr.getBytes("UTF-8"));
        @Cleanup ByteArrayOutputStream out = new ByteArrayOutputStream();
        byte[] b = new byte[1024];
        while (true) {
            int r = in.read(b);
            if (r == -1) break;
            out.write(b, 0, r);
        }
        String outStr = out.toString("UTF-8");
        System.out.println(outStr);
    }
}
```

#### @ToString

把所有类属性都编写到toString方法中方便打印日志，是一件多么枯燥无味的事情。使用@ToString注解可以自动生成toString方法，默认会包含所有类属性，使用@ToString.Exclude注解可以排除属性的生成

```java
/**
 * @auther macrozheng
 * @description @ToString注解使用示例
 * @date 2020/12/17
 * @github https://github.com/macrozheng
 */
@ToString
public class ToStringExample {
    @ToString.Exclude
    private Long id;
    private String name;
    private Integer age;
    public ToStringExample(Long id,String name,Integer age){
        this.id =id;
        this.name = name;
        this.age = age;
    }

    public static void main(String[] args) {
        ToStringExample example = new ToStringExample(1L,"test",20);
        //自动实现toString方法，输出ToStringExample(name=test, age=20)
        System.out.println(example);
    }
}
```

编译后Lombok会生成如下代码。

```java
public class ToStringExample {
    private Long id;
    private String name;
    private Integer age;

    public ToStringExample(Long id, String name, Integer age) {
        this.id = id;
        this.name = name;
        this.age = age;
    }

    public String toString() {
        return "ToStringExample(name=" + this.name + ", age=" + this.age + ")";
    }
}
```

#### @EqualsAndHashCode

使用@EqualsAndHashCode注解可以自动生成hashCode和equals方法，默认包含所有类属性，使用@EqualsAndHashCode.Exclude可以排除属性的生成。

```java
/**
 * @auther macrozheng
 * @description @EqualsAndHashCode使用示例
 * @date 2020/12/17
 * @github https://github.com/macrozheng
 */
@Getter
@Setter
@EqualsAndHashCode
public class EqualsAndHashCodeExample {
    private Long id;
    @EqualsAndHashCode.Exclude
    private String name;
    @EqualsAndHashCode.Exclude
    private Integer age;

    public static void main(String[] args) {
        EqualsAndHashCodeExample example1 = new EqualsAndHashCodeExample();
        example1.setId(1L);
        example1.setName("test");
        example1.setAge(20);
        EqualsAndHashCodeExample example2 = new EqualsAndHashCodeExample();
        example2.setId(1L);
        //equals方法只对比id，返回true
        System.out.println(example1.equals(example2));
    }
}
```

#### @Value

使用@Value注解可以把类声明为不可变的，声明后此类相当于final类，无法被继承，其属性也会变成final属性。

#### @Builder

使用@Builder注解可以通过建造者模式来创建对象，建造者模式加链式调用，创建对象太方便了！

```java
/**
 * @auther macrozheng
 * @description @Builder注解使用示例
 * @date 2020/12/17
 * @github https://github.com/macrozheng
 */
@Builder
@ToString
public class BuilderExample {
    private Long id;
    private String name;
    private Integer age;

    public static void main(String[] args) {
        BuilderExample example = BuilderExample.builder()
                .id(1L)
                .name("test")
                .age(20)
                .build();
        System.out.println(example);
    }
}
```

#### @SneakyThrows

还在手动捕获并抛出异常？使用@SneakyThrows注解自动实现试试！

```java
/**
 * @auther macrozheng
 * @description @SneakyThrows注解使用示例
 * @date 2020/12/17
 * @github https://github.com/macrozheng
 */
public class SneakyThrowsExample {

    //自动抛出异常，无需处理
    @SneakyThrows(UnsupportedEncodingException.class)
    public static byte[] str2byte(String str){
        return str.getBytes("UTF-8");
    }

    public static void main(String[] args) {
        String str = "Hello World!";
        System.out.println(str2byte(str).length);
    }
}
```

编译后Lombok会生成如下代码。

```java
public class SneakyThrowsExample {
    public SneakyThrowsExample() {
    }

    public static byte[] str2byte(String str) {
        try {
            return str.getBytes("UTF-8");
        } catch (UnsupportedEncodingException var2) {
            throw var2;
        }
    }
}
```

#### @With

使用@With注解可以实现对原对象进行克隆，并改变其一个属性，使用时需要指定全参构造方法。

```java
/**
 * @auther macrozheng
 * @description @With注解使用示例
 * @date 2020/12/17
 * @github https://github.com/macrozheng
 */
@With
@AllArgsConstructor
public class WithExample {
    private Long id;
    private String name;
    private Integer age;

    public static void main(String[] args) {
        WithExample example1 = new WithExample(1L, "test", 20);
        WithExample example2 = example1.withAge(22);
        //将原对象进行clone并设置age，返回false
        System.out.println(example1.equals(example2));
    }
}
```

#### @Slf4j

使用Lombok生成日志对象时，根据使用日志实现的不同，有多种注解可以使用。比如**@Log、@Log4j、@Log4j2、@Slf4j**等。

# Hutool使用教程

### Convert

类型转换工具类，用于各种类型数据的转换。平时我们转换类型经常会面临类型转换失败的问题，要写`try catch`代码，有了它，就不用写了！

```java
//转换为字符串
int a = 1;
String aStr = Convert.toStr(a);
//转换为指定类型数组
String[] b = {"1", "2", "3", "4"};
Integer[] bArr = Convert.toIntArray(b);
//转换为日期对象
String dateStr = "2017-05-06";
Date date = Convert.toDate(dateStr);
//转换为列表
String[] strArr = {"a", "b", "c", "d"};
List<String> strList = Convert.toList(String.class, strArr);
```

### DateUtil

日期时间工具类，定义了一些常用的日期时间操作方法。JDK自带的Date和Calendar对象真心不好用，有了它操作日期时间就简单多了！

```java
//Date、long、Calendar之间的相互转换
//当前时间
Date date = DateUtil.date();
//Calendar转Date
date = DateUtil.date(Calendar.getInstance());
//时间戳转Date
date = DateUtil.date(System.currentTimeMillis());
//自动识别格式转换
String dateStr = "2017-03-01";
date = DateUtil.parse(dateStr);
//自定义格式化转换
date = DateUtil.parse(dateStr, "yyyy-MM-dd");
//格式化输出日期
String format = DateUtil.format(date, "yyyy-MM-dd");
//获得年的部分
int year = DateUtil.year(date);
//获得月份，从0开始计数
int month = DateUtil.month(date);
//获取某天的开始、结束时间
Date beginOfDay = DateUtil.beginOfDay(date);
Date endOfDay = DateUtil.endOfDay(date);
//计算偏移后的日期时间
Date newDate = DateUtil.offset(date, DateField.DAY_OF_MONTH, 2);
//计算日期时间之间的偏移量
long betweenDay = DateUtil.between(date, newDate, DateUnit.DAY);
```

### ClassPathResource

ClassPath单一资源访问类，可以获取classPath下的文件，在Tomcat等容器下，classPath一般是WEB-INF/classes。

```java
//获取定义在src/main/resources文件夹中的配置文件
ClassPathResource resource = new ClassPathResource("generator.properties");
Properties properties = new Properties();
properties.load(resource.getStream());
LOGGER.info("/classPath:{}", properties);
```

### NumberUtil

数字处理工具类，可用于各种类型数字的加减乘除操作及类型判断。

```java
double n1 = 1.234;
double n2 = 1.234;
double result;
//对float、double、BigDecimal做加减乘除操作
result = NumberUtil.add(n1, n2);
result = NumberUtil.sub(n1, n2);
result = NumberUtil.mul(n1, n2);
result = NumberUtil.div(n1, n2);
//保留两位小数
BigDecimal roundNum = NumberUtil.round(n1, 2);
String n3 = "1.234";
//判断是否为数字、整数、浮点数
NumberUtil.isNumber(n3);
NumberUtil.isInteger(n3);
NumberUtil.isDouble(n3);
```

### BeanUtil

JavaBean工具类，可用于Map与JavaBean对象的互相转换以及对象属性的拷贝。

```java
PmsBrand brand = new PmsBrand();
brand.setId(1L);
brand.setName("小米");
brand.setShowStatus(0);
//Bean转Map
Map<String, Object> map = BeanUtil.beanToMap(brand);
LOGGER.info("beanUtil bean to map:{}", map);
//Map转Bean
PmsBrand mapBrand = BeanUtil.toBean(map, PmsBrand.class);
LOGGER.info("beanUtil map to bean:{}", mapBrand);
//Bean属性拷贝
PmsBrand copyBrand = new PmsBrand();
BeanUtil.copyProperties(brand, copyBrand);
LOGGER.info("beanUtil copy properties:{}", copyBrand);
```

### Validator

字段验证器，可以对不同格式的字符串进行验证，比如邮箱、手机号、IP等格式。

```java
//判断是否为邮箱地址
boolean result = Validator.isEmail("macro@qq.com");
LOGGER.info("Validator isEmail:{}", result);
//判断是否为手机号码
result = Validator.isMobile("18911111111");
LOGGER.info("Validator isMobile:{}", result);
//判断是否为IPV4地址
result = Validator.isIpv4("192.168.3.101");
LOGGER.info("Validator isIpv4:{}", result);
//判断是否为汉字
result = Validator.isChinese("你好");
LOGGER.info("Validator isChinese:{}", result);
//判断是否为身份证号码（18位中国）
result = Validator.isCitizenId("123456");
LOGGER.info("Validator isCitizenId:{}", result);
//判断是否为URL
result = Validator.isUrl("http://www.baidu.com");
LOGGER.info("Validator isUrl:{}", result);
//判断是否为生日
result = Validator.isBirthday("2020-02-01");
LOGGER.info("Validator isBirthday:{}", result);
```

