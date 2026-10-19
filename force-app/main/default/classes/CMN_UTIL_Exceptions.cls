/**
 * @description This code is part of the "apex-lang" open-source project release 1.18 available at:
 * <p/>
 * http://code.google.com/p/apex-lang/
 * <p/>
 * Copyright (2012) richard van hook
 * <p/>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p/>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p/>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * <p/>
 * This project code has been forked and to update the latest salesforce APIs.
 * <p/>
 * common API exceptions used by apex-lang
 * consolidated exceptions under a single container class to reduce number of files
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 */
global class CMN_UTIL_Exceptions {
  /**
   * @description illegal state exception
   */
  global class IllegalStateException extends Exception {
  }

  /**
   * @description invalid character string exception
   */
  global class InvalidCharacterStringException extends Exception {
  }
}