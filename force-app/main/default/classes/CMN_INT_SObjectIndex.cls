/**
 * @description For implementing CMN_UTIL_SObjectIndex with the Composite Pattern
 * <p/>
 * MIT License
 * <p/>
 * Copyright (c) 2018 Aidan Harding, Nebula Consulting
 * <p/>
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * <p/>
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * <p/>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * <p/>
 * https://nebulaconsulting.co.uk/insights/sobjectindex-the-class-you-can-use-everywhere/
 *
 * @author aidan@nebulaconsulting.co.uk
 *
 * @date 14/11/2018

<p>VCCC-378</p>
 */
public interface CMN_INT_SObjectIndex {
  CMN_INT_SObjectIndex put(SObject newObj);

  List<SObject> getAll(Map<String, Object> spec);

  List<SObject> getAll(Object key);

  List<SObject> getAll(SObject spec);

  List<SObject> remove(Map<String, Object> spec);

  List<SObject> remove(SObject spec);

  List<SObject> values();

  Set<String> keySet(String field);
}