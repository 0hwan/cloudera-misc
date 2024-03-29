Sentry to Ranger – 간결한 가이드
CDP(Cloudera Data Platform) 는 Cloudera Enterprise Data Hub(CDH) 및 Hortonworks Data Platform(HDP) 의 두 가지 레거시 플랫폼 기술을 병합하여 고객에게 많은 개선 사항을 제공합니다 . CDP에는 보안 및 거버넌스에서 이전에 존재했던 일부 기능에 대한 우수한 대안뿐만 아니라 새로운 기능이 포함되어 있습니다. CDH 사용자를 위한 이러한 주요 변경 사항 중 하나는 인증 및 액세스 제어를 위해 Sentry를 Ranger로 대체한 것입니다. 

사용자가 많은 여러 사업부에서 사용하는 Cloudera의 스택과 같은 빅 데이터 플랫폼의 경우 마이너 버전이라도 업그레이드하는 것은 사용자와 비즈니스에 미치는 영향을 줄이기 위해 잘 계획된 활동이어야 합니다. 따라서 CDP에서 새로운 메이저 버전으로 업그레이드하면 망설임과 불안감이 생길 수 있습니다. 올바른 정보 세트에 액세스할 수 있으면 사용자가 미리 준비하고 업그레이드 프로세스의 장애물을 제거하는 데 도움이 됩니다. 이 블로그 게시물은 CDH 사용자에게 CDP의 Hadoop SQL 정책을 Sentry로 대체하는 Ranger에 대한 간략한 개요를 제공합니다.

레인저로 전환하는 이유는 무엇입니까?
Apache Sentry는 Hadoop의 특정 구성 요소에 대한 역할 기반 인증 모듈입니다. Hadoop 클러스터의 사용자에 대해 데이터에 대한 다양한 수준의 권한을 정의하고 적용하는 데 유용합니다. CDH에서 Apache Sentry는 Apache Hive 및 Apache Impala와 같은 Hadoop SQL 구성 요소와 Apache Solr, Apache Kafka 및 HDFS(Hive 테이블 데이터로 제한됨)와 같은 기타 서비스에 대한 독립 실행형 인증 모듈을 제공했습니다. Sentry는 시각적 정책 관리를 위해 Hue를, CDH 플랫폼에서 데이터 액세스 감사를 위해 Cloudera Navigator를 사용했습니다. 

반면 Apache Ranger는 Hadoop 플랫폼 전체에서 데이터 보안을 활성화, 관리 및 모니터링할 수 있는 포괄적인 보안 프레임워크를 제공합니다. Sentry가 보호하는 모든 Hadoop 구성 요소와 Apache HBase, YARN, Apache NiFi와 같은 Apache Hadoop 에코시스템의 추가 서비스에서 보안 정책을 일관되게 정의, 관리 및 관리할 수 있는 중앙 집중식 플랫폼을 제공합니다. 또한 Apache Ranger는 이제 Amazon S3 및 ADLS(Azure Data Lake Store)와 같은 공용 클라우드 개체 저장소를 지원합니다. 또한 Ranger는 모든 액세스 요청을 실시간으로 추적하는 중앙 집중식 감사 위치를 통해 보안 관리자에게 환경에 대한 깊은 가시성을 제공합니다. 

Apache Ranger에는 Hue 서비스를 통해 제공되는 Sentry의 웹 인터페이스에 대한 우수한 대안인 자체 웹 사용자 인터페이스(웹 UI)가 있습니다. Ranger 웹 UI는 Ranger KMS 서비스를 사용하는 키 관리자를 위한 별도의 로그인과 함께 보안 키 관리에도 사용할 수 있습니다. 또한 Apache Ranger는 열 마스킹 및 행 필터링과 같이 매우 필요한 보안 기능을 즉시 제공합니다. 또 다른 중요한 요소는 Ranger의 액세스 정책이 지리적 지역, 하루 중 시간 등과 같은 다양한 속성을 사용하여 동적 컨텍스트로 사용자 정의할 수 있다는 것입니다. 아래 표는 Sentry와 Ranger 간의 기능을 자세히 비교한 것입니다. 



 

Sentry to Ranger - 몇 가지 행동 변화
위에서 제안한 것처럼 Sentry와 Ranger는 완전히 다른 제품이며 아키텍처와 구현에서 큰 차이가 있습니다. CDH의 Sentry에서 CDP의 Ranger로 마이그레이션할 때 눈에 띄는 몇 가지 동작 변경 사항은 다음과 같습니다.

Sentry의 상속 모델 대 Ranger의 명시적 모델
Sentry에서 계층 구조의 컨테이너 객체에 부여된 모든 권한은 그 안에 있는 기본 객체에 의해 자동으로 상속됩니다. 예를 들어 사용자에게 데이터베이스 범위에 대한 모든 권한이 있는 경우 해당 사용자는 테이블 및 열과 같이 해당 범위 내에 포함된 모든 기본 개체에 대한 모든 권한을 가집니다. 따라서 데이터베이스의 사용자에게 부여된 하나의 권한은 데이터베이스 내의 모든 개체에 대한 액세스 권한을 부여합니다.
Ranger에서 사용자가 개체에 액세스하려면 필요한 권한이 있는 명시적인 Hadoop SQL 정책이 있어야 합니다. 즉, Ranger는 더 세분화된 수준의 액세스 제어를 제공합니다. 데이터베이스 수준에서 액세스 권한을 갖는 것은 테이블 수준에서 동일한 액세스 권한을 부여하지 않습니다. 그리고 테이블 수준에서 액세스 권한을 갖는 것은 열 수준에서 동일한 액세스 권한을 부여하지 않습니다. 예를 들어 Ranger Hadoop SQL 정책을 사용하여 사용자에게 모든 테이블과 열에 대한 액세스 권한을 부여하려면 데이터베이스 → , 테이블 → * 및 열 → *와 같은 와일드카드를 사용하여 정책을 만듭니다.


액세스 제어 구현 – Sentry 대 Ranger
Hive에 대한 Sentry Authorization 처리는 HiveServer2에서 실행되는 시맨틱 후크를 통해 발생합니다. 액세스 요청은 유효성 검사를 위해 매번 Sentry Server로 돌아갑니다. Impala의 액세스 제어 검사는 Hive와 같습니다. Impala의 주요 차이점은 Impala 카탈로그 서버에 의한 Sentry 메타데이터(권한)의 캐싱입니다.


Ranger 기반 인증을 지원하는 CDP Private Cloud Base 내의 모든 서비스에는 연결된 Ranger 플러그인이 있습니다. 이러한 Ranger 플러그인은 클라이언트 측에서 액세스 권한 및 태그를 캐시합니다. 또한 변경 사항에 대해 권한 및 태그 저장소를 주기적으로 폴링합니다. 변경 사항이 감지되면 캐시가 자동으로 업데이트됩니다. 이러한 구현 모델을 사용하면 Ranger 플러그인이 서비스 데몬 내에서 인증 요청을 완전히 처리할 수 있으므로 상당한 성능 향상과 서비스 외부 장애에 대한 복원력을 얻을 수 있습니다.


HDFS 액세스 동기화 구현 – Sentry 대 Ranger
Sentry에는 HDFS에 대한 액세스를 제공하기 위해 SQL 권한을 자동으로 변환하는 옵션이 있습니다. 이는 특정 HDFS 디렉터리에 대한 HDFS ACL과 Sentry 권한의 동기화를 구성할 수 있는 HDFS-Sentry 플러그인을 통해 구현됩니다. 동기화가 활성화되면 Sentry는 데이터베이스 및 테이블에 대한 권한을 HDFS의 기본 파일에 대한 해당 HDFS ACL로 변환합니다. HDFS 파일에 대한 이러한 추가 액세스 권한은 HDFS 명령을 사용하여 확장 ACL을 나열하여 볼 수 있습니다.
CDP Private Cloud Base 7.1.5부터 동일한 목적을 제공하는 RMS(Ranger Resource Mapping Server) 기능이 도입되었습니다. RMS는 기술 프리뷰로 CDP Private Cloud Base 7.1.4에서 사용할 수 있습니다. Sentry에서 HDFS ACL 동기화 구현은 Ranger RMS가 Hive에서 HDFS로의 액세스 정책 자동 변환을 처리하는 방식과 다릅니다. 그러나 기본 개념 및 권한 부여 결정은 테이블 수준 액세스에 대해 동일합니다. 이 새로운 기능에 대해 자세히 알아보려면 Ranger RMS에 대한 이 블로그 게시물을 읽으십시오 .


SQL의 HDFS 위치에 대한 액세스 권한 – Sentry 대 Ranger
Sentry에서 다음 작업을 수행하려면 위치에 대한 URI 권한이 필요했습니다. 
명시적으로 테이블 위치 설정 – 외부 테이블 생성
테이블 위치 변경 – 테이블 변경
위치가 있는 테이블에서 가져오기 및 내보내기
jar 파일에서 함수 만들기 
 

Ranger에서는 Hadoop SQL의 "URL" 정책 또는 Hive 개체에서 사용하는 위치에 대한 HDFS 정책을 사용하여 위치를 사용하는 활동에 동일한 효과를 줄 수 있습니다. 함수를 생성하려면 Hadoop SQL의 "udf" 정책에 적절한 권한이 필요합니다.
 

Ranger의 특수 엔티티
그룹 "공용" – 이것은 시스템에 존재하는 모든 인증된 사용자로 구성된 Ranger 내의 특수 내부 그룹입니다. 회원 자격은 암시적이고 자동적입니다. 모든 사용자는 이 그룹의 일부가 되며 이 그룹에 부여된 모든 정책은 모든 사용자에게 액세스를 제공합니다. 다음은 이 특수 그룹 "공용"에 권한을 부여하는 기본 정책입니다. 보안 요구 사항에 따라 이러한 기본 정책에서 "공용"을 제거하여 사용자 액세스를 추가로 제한할 수 있습니다.
모두 – 데이터베이스 ⇒ 공개 ⇒ 생성 권한
사용자가 셀프 서비스로 자신의 데이터베이스를 생성할 수 있습니다.
기본 데이터베이스 테이블 열 ⇒ 공개 ⇒ 생성 권한
사용자가 기본 데이터베이스에서 셀프 서비스로 테이블을 생성할 수 있습니다.
Information_schema 데이터베이스 테이블 열 ⇒ 공개 ⇒ 권한 선택
사용자가 테이블, 보기, 열 및 Hive 권한에 대한 정보를 쿼리할 수 있습니다.
 

특수 개체 {OWNER} – 이것은 사용자의 행동에 따라 사용자에게 연결되는 Ranger 내의 특수 개체로 간주되어야 합니다. 이 특수 개체를 사용하면 정책 구조를 크게 단순화할 수 있습니다. 예를 들어 사용자 "bob"이 테이블을 생성하면 "bob"은 해당 테이블의 {OWNER}가 되고 모든 정책에서 해당 테이블에 대해 {OWNER}에게 제공된 모든 권한을 얻습니다. 다음은 {OWNER}에 대한 권한이 있는 기본 정책입니다. 권장되지는 않지만 보안 요구 사항에 따라 이 특수 엔터티에 대한 액세스를 변경할 수 있습니다. 기본 {OWNER} 권한을 제거하려면 각 개체 소유자에 대한 특정 정책을 추가해야 할 수 있으며, 이로 인해 정책 관리의 운영 부담이 증가할 수 있습니다.
모두 – 데이터베이스, 테이블, 열 ⇒ {OWNER} ⇒ 모든 권한
모두 – 데이터베이스, 테이블 ⇒ {OWNER} ⇒ 모든 권한
모두 – 데이터베이스, udf ⇒ {OWNER} ⇒ 모든 권한
모두 – 데이터베이스 ⇒ {OWNER} ⇒ 모든 권한
 

특수 개체 {USER} – "현재 사용자"를 의미하는 Ranger 내의 특수 개체로 간주되어야 합니다. 이 특수 개체를 사용하면 데이터 리소스에 사용자 이름 특성 값이 포함된 정책 구조를 크게 단순화할 수 있습니다. 예를 들어 HDFS 경로 /home/{USER}에서 {USER}에게 액세스 권한을 부여하면 사용자 "bob"은 "/home/bob"에 액세스하고 사용자 "kiran"은 "/home/kiran"에 액세스할 수 있습니다. 마찬가지로 데이터베이스 db_{USER}에서 {USER}에게 액세스 권한을 부여하면 사용자 "bob"은 "db_bob"에 액세스하고 사용자 "kiran"은 "db_kiran"에 액세스할 수 있습니다.
이 변경 사항이 내 환경에 어떤 영향을 줍니까?
레인저로 마이그레이션 
Cloudera는 Sentry에서 Ranger로 마이그레이션하기 위한 자동화 도구인 authzmigrator 를 제공합니다.
이 도구는 Hive 개체의 권한 및 URL 권한(예: Sentry의 URI)과 CDH 클러스터의 Sentry에 있는 Kafka 권한을 변환합니다.
현재 이 도구는 Cloudera 검색용 Sentry(Solr)를 통해 활성화된 인증 권한을 다루지 않습니다.
이 도구에는 잘 정의된 2단계 프로세스가 있습니다. (1) 소스의 Sentry에서 권한 내보내기 (2) 내보낸 파일을 CDP의 Ranger 서비스로 수집 
이 도구는 CDH에서 CDP로의 직접 업그레이드 및 사이드카 마이그레이션 방식 모두에서 작동합니다.
직접 업그레이드의 경우 전체 프로세스가 자동화됩니다.
사이드카 마이그레이션의 경우 authzmigrator 도구 에 대한 수동 절차가 정의됩니다.
 

Ranger의 개체 권한
Sentry의 "삽입" 권한은 이제 Ranger Hadoop SQL 정책의 "업데이트" 권한에 매핑됩니다.
Sentry의 "URI" 권한은 이제 Ranger Hadoop SQL의 "URL" 정책에 매핑됩니다.
추가 세분화된 권한은 Ranger Hadoop SQL에 있습니다.
드롭, 변경, 인덱스, 잠금 등
 

Ranger와 Hive-HDFS 액세스 동기화
새로운 서비스인 Ranger RMS를 배포해야 합니다. 
Ranger RMS는 Ranger가 사용하는 동일한 데이터베이스에 연결합니다.
Ranger RMS는 현재 데이터베이스 수준이 아닌 테이블 수준 동기화만 작동합니다(출시 예정).
 

Hive에서 Ranger로 외부 테이블 생성
Hive에서 사용자 지정 LOCATION 절을 사용하여 외부 테이블을 생성할 때 다음 추가 액세스 중 하나가 필요합니다(1) 또는 (2).
(1) 사용자는 HDFS 위치에 대한 직접 읽기 및 쓰기 액세스 권한이 있어야 합니다.
이것은 Ranger 또는 HDFS POSIX 권한 또는 HDFS ACL의 HDFS 정책을 통해 제공될 수 있습니다.
(2) 사용자에게 테이블에 대해 정의된 HDFS 위치에 대한 읽기 및 쓰기 권한을 제공하는 Ranger Hadoop SQL 정책의 URL 정책
URL에는 슬래시 문자('/')가 없어야 합니다.
위치 경로가 사용자 소유가 아닌 경우 "ranger.plugin.hive.urlauth.filesystem.schemes" 구성이 "hdfs:,file:"이 아닌 "file:"로 설정되어 있는지 확인하십시오(기본값 ) Hive 및 Hive on Tez 서비스 모두에서
사용자 "hive"는 테이블의 HDFS 위치에 대한 모든 권한을 가져야 합니다.
 

요약
Apache Ranger는 Cloudera Data Platform 아키텍처의 기본 부분이며 데이터 관리 및 데이터 거버넌스에 중요한 SDX(Shared Data Experience)의 일부로 권한 부여를 지원합니다. CDP에서 Ranger는 Apache Sentry가 CDH 스택에서 제공한 모든 기능을 제공합니다. Ranger는 전체 CDP 에코시스템에서 데이터 보안을 활성화, 관리 및 모니터링할 수 있는 포괄적인 솔루션입니다. 또한 데이터 필터링 및 마스킹과 같은 추가 보안 기능을 제공합니다. Ranger는 인증과 감사를 결합하여 CDP의 데이터 보안 전략을 강화하고 우수한 사용자 경험을 제공합니다. 이러한 권한 부여 및 감사 향상 외에도 Ranger 웹 UI는 Ranger KMS 서비스를 사용하는 키 관리자를 위한 별도의 로그인을 통해 보안 키 관리에 사용할 수도 있습니다. 