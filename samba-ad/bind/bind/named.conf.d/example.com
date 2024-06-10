//zone "example.org" IN {
//    type slave;
//    file "example.zone";
//    masters {
//        192.168.1.100;
//    };
//    allow-query { any; };
//    allow-transfer { any; };
//};
